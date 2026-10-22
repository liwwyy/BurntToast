#!/usr/bin/env python3
"""Pack contract checks and CPU numerical sanity checks (not visual tests)."""
from pathlib import Path
import hashlib
import re
import tempfile
import unittest
import zipfile

import package
import validate

ROOT = Path(__file__).resolve().parents[2]
SHADERS = ROOT / "shaders"


def scalar_options():
    result = {}
    for path in SHADERS.rglob("*"):
        if path.suffix not in (".glsl", ".fsh", ".vsh"):
            continue
        for line in path.read_text().splitlines():
            match = re.match(r"\s*#define\s+(\w+)\s+(\S+)\s*//\s*\[([^]]+)\]", line)
            if not match:
                match = re.match(r"\s*const\s+(?:int|float)\s+(\w+)\s*=\s*([^;]+);\s*//\s*\[([^]]+)\]", line)
            if match:
                name, default, values = match.groups()
                default = default.strip()
                if name in result and result[name][0] != default:
                    raise AssertionError(f"Conflicting option default for {name}")
                result[name] = (default, values.split())
    return result


class PackChecks(unittest.TestCase):
    def test_all_includes_and_program_pairs(self):
        for vertex in validate.entrypoints():
            self.assertTrue(vertex.with_suffix(".fsh").exists(), vertex)
            for ext in (".fsh", ".vsh"):
                expanded = validate.expand(vertex.with_suffix(ext))
                self.assertEqual(expanded.count("#version"), 1, vertex)
                self.assertNotIn("\0", expanded)

    def test_options_are_exposed_and_discoverable_by_iris(self):
        scalars = scalar_options()
        for name, (default, values) in scalars.items():
            self.assertIn(float(default), [float(v) for v in values], name)
        sources = "\n".join(validate.expand(p) for p in validate.entrypoints())
        sources += "\n" + "\n".join(validate.expand(p.with_suffix(".fsh")) for p in validate.entrypoints())
        booleans = set(re.findall(r"(?m)^[ \t]*(?://[ \t]*)?#define[ \t]+(\w+)[ \t]*(?://[^\n]*)?$", sources))
        references = set(re.findall(r"#ifn?def\s+(\w+)", sources))
        # Iris deliberately ignores '#if defined(...)' when discovering switches.
        available = set(scalars) | (booleans & references)
        properties = (SHADERS / "shaders.properties").read_text()
        for line in properties.splitlines():
            if re.match(r"screen(?:\.\w+)?\s*=", line) and not line.startswith("screen.columns"):
                for option in line.split("=", 1)[1].split():
                    if not option.startswith(("<", "[")):
                        self.assertIn(option, available, f"Iris cannot discover menu option {option}")
            if line.startswith("sliders="):
                for option in line.split("=", 1)[1].split():
                    self.assertIn(option, scalars)

    def test_reference_defaults_and_profiles(self):
        options = scalar_options()
        expected = {"MOTION_BLUR_STRENGTH": 5.5, "MOTION_BLUR_SAMPLES": 8,
                    "VANILLA_GAMMA": 1.0, "MIN_VISIBILITY_STRENGTH": 0.08,
                    "FOG_START": 0.90, "FOG_END": 1.0, "FOG_STRENGTH": 0.25,
                    "WATER_OPACITY": 0.45, "shadowMapResolution": 768, "shadowDistance": 48}
        for name, value in expected.items():
            self.assertEqual(float(options[name][0]), value, name)
        settings = (SHADERS / "lib/settings.glsl").read_text()
        self.assertRegex(settings, r"(?m)^#define SUN_GLARE$")
        for switch in ("WATER_WAVES", "WATER_RIPPLES"):
            self.assertRegex(settings, rf"(?m)^//#define {switch}$")
        properties = (SHADERS / "shaders.properties").read_text()
        for line in properties.splitlines():
            if line.startswith("profile."):
                for token in line.split("=", 1)[1].split():
                    if "=" in token:
                        name, value = token.split("=", 1)
                        self.assertIn(float(value), [float(v) for v in options[name][1]], name)

    def test_ch_motion_reference_is_copied_unchanged(self):
        # Hashes of the two original files in the supplied CH_MotionV4.zip.
        self.assertEqual(hashlib.sha256((SHADERS / "program/ch_motion/MotionBlur.glsl").read_bytes()).hexdigest(),
                         "3de72df60bc9ecc27625e2011f1ec170132e3d4006ef6ce93ffff70c8146f45a")
        for folder in ("", "world0", "world-1", "world1"):
            self.assertEqual(hashlib.sha256((SHADERS / folder / "final.vsh").read_bytes()).hexdigest(),
                             "f2bbbf92776f7c80a680887af39e9deef8d11e86fdae2581533e5a47b1efe2dc")

    def test_release_assets_and_defaults(self):
        self.assertFalse((ROOT / "LOCAL_ONLY.md").exists())
        self.assertTrue((ROOT / "licenses/Complementary-License.txt").is_file())
        self.assertTrue((SHADERS / "texture/complementary-noise.png").read_bytes().startswith(b"\x89PNG\r\n\x1a\n"))
        properties = (SHADERS / "shaders.properties").read_text()
        self.assertIn("texture.composite.btEndNoise=texture/complementary-noise.png", properties)
        fast = next(line for line in properties.splitlines() if line.startswith("profile.FAST="))
        self.assertIn(" SUN_GLARE", fast)
        self.assertNotIn("!SUN_GLARE", fast)

    def test_hands_have_mask_and_explicit_translucent_programs(self):
        for folder in ("", "world0", "world-1", "world1"):
            for name in ("gbuffers_hand", "gbuffers_hand_water"):
                source = validate.expand(SHADERS / folder / f"{name}.fsh")
                self.assertIn("DRAWBUFFERS:12", source)
                self.assertIn("gl_FragData[1] = vec4(1.0)", source)
                self.assertIn("discard", source)
                self.assertIn("btHandLight", source)
        directives = (SHADERS / "lib/buffers.glsl").read_text()
        self.assertIn("colortex2Clear = true", directives)
        self.assertIn("colortex2ClearColor = vec4(0.0, 0.0, 0.0, 0.0)", directives)

    def test_iris_clear_color_directive_uses_four_literals(self):
        for vertex in validate.entrypoints():
            validate.validate_iris_directives(validate.expand(vertex.with_suffix(".fsh")))
        for invalid in ("vec4(0.0)", "vec4(0.0, 0.0)", "vec4(0.0, 0.0, 0.0, 1.0 / 2.0)"):
            with self.assertRaises(ValueError):
                validate.validate_iris_directives(f"const vec4 colortex2ClearColor = {invalid};")
        validate.validate_iris_directives("const vec4 colortex2ClearColor = vec4(0.0, 0.0, 0.0, 0.0);")

    def test_format_directives_are_comments_not_glsl_constants(self):
        source = (SHADERS / "lib/buffers.glsl").read_text()
        comments = "\n".join(re.findall(r"/\*(.*?)\*/", source, re.S))
        formats = dict(re.findall(r"(?m)^const int (colortex\d+Format) = (\w+);$", comments))
        self.assertEqual(formats, {"colortex0Format": "RGB8", "colortex1Format": "R11F_G11F_B10F",
                                   "colortex2Format": "R8", "colortex4Format": "R11F_G11F_B10F"})
        executable = re.sub(r"/\*.*?\*/|//[^\n]*", "", source, flags=re.S)
        self.assertNotRegex(executable, r"const int colortex\d+Format")
        validator_source = (ROOT / ".github/scripts/validate.py").read_text()
        for name in ("RGB8", "R8", "R11F_G11F_B10F"):
            self.assertNotIn(f"#define {name} ", validator_source)

    def test_disabling_boolean_does_not_remove_next_option(self):
        source = validate.expand(SHADERS / "world0/composite.fsh", {"FOG_ENABLED": None})
        self.assertIn("#define FOG_START 0.90", source)
        self.assertNotIn("#define FOG_ENABLED\n", source)

    def test_fog_boundaries_and_reversed_ranges(self):
        # CPU reference of the specified edge ramp; shader compilation is separate.
        def ramp(distance, far, start=0.90, end=1.0):
            high = max(end * far, 1.0)
            low = min(start * far, high - 0.01)
            t = max(0.0, min(1.0, (distance - low) / (high - low)))
            return t * t * (3.0 - 2.0 * t)
        for far in (32, 128, 512, 1024):
            self.assertEqual(ramp(0.89 * far, far), 0.0)
            self.assertAlmostEqual(ramp(0.95 * far, far), 0.5)
            self.assertEqual(ramp(far, far), 1.0)
            self.assertTrue(0.0 <= ramp(far, far, 0.98, 0.25) <= 1.0)

    def test_blur_energy_and_surface_floor_reference(self):
        # Constant-color scenes must retain brightness at every supported count.
        for setting in (4, 6, 8, 10, 12, 16, 20, 24):
            count = 2 * ((setting - 1) // 2) + 1  # CH's unchanged centered odd count.
            for accepted in range(1, count + 1):
                self.assertAlmostEqual(sum([0.37] * accepted) / accepted, 0.37)
        minimum = float(scalar_options()["MIN_VISIBILITY_STRENGTH"][0])
        for lighting in (0.0, 0.001, 0.01, 0.1, 1.0, 100.0):
            actual = max(lighting, minimum)
            self.assertGreaterEqual(actual, minimum)
            self.assertEqual(actual * 0.0, 0.0)  # Preserve black texture pixels.
            if lighting >= minimum:
                self.assertEqual(actual, lighting)

    def test_reproducible_package_and_root_layout(self):
        with tempfile.TemporaryDirectory() as directory:
            first = package.build(Path(directory) / "first")
            second = package.build(Path(directory) / "second")
            self.assertEqual(first.read_bytes(), second.read_bytes())
            with zipfile.ZipFile(first) as pack:
                self.assertIsNone(pack.testzip())
                names = pack.namelist()
                self.assertIn("shaders/shaders.properties", names)
                self.assertIn("CREDITS.txt", names)
                self.assertIn("LICENSE.md", names)
                self.assertNotIn("LOCAL_ONLY.md", names)
                self.assertIn("licenses/Complementary-License.txt", names)
                self.assertFalse(any(n.startswith(("reference/", ".github/", ".build/")) for n in names))
                version = (ROOT / "VERSION").read_text().strip()
                self.assertEqual(first.name, f"BurntToast_v{version}_.Chocapic13_Toaster_edit.zip")
                self.assertIn(f"BurntToast {version}", pack.read("shaders/shaders.properties").decode())


if __name__ == "__main__":
    unittest.main(verbosity=2)
