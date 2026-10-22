#!/usr/bin/env python3
"""Validate includes, options, program pairs and GLSL without running Minecraft."""
import argparse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
SHADERS = ROOT / "shaders"
VARIANTS = {
    "default": {},
    "disabled": {k: None for k in (
        "MOTION_BLUR", "MOTION_BLUR_NOISE", "EXCLUDE_HAND_MOTION_BLUR",
        "REMOVE_HAND_TINT", "REMOVE_ENTITY_DIMENSION_TINT", "MINIMUM_VISIBILITY",
        "FOG_ENABLED", "TRANSPARENT_WATER", "SUN_GLARE", "END_STARS", "END_SKY_TEXTURE",
        "WAVING_LEAVES", "WAVING_PLANTS", "WAVING_VINES", "WAVING_FIRE")},
    "effects": {"WAVING_LEAVES": "", "WAVING_PLANTS": "",
                "WAVING_VINES": "", "WAVING_FIRE": "", "WATER_WAVES": "", "WATER_RIPPLES": "", "TONEMAP_ACES": "",
                "VANILLA_GAMMA": "1.5", "MOTION_BLUR_SAMPLES": "24"},
    "fast": {"MOTION_BLUR_SAMPLES": "4", "shadowMapResolution": "512",
             "shadowDistance": "32.0"},
    "minimum": {"MIN_VISIBILITY_STRENGTH": "0.0", "FOG_START": "0.98",
                "FOG_END": "0.25", "FOG_STRENGTH": "0.0",
                "MOTION_BLUR_STRENGTH": "0.5", "WATER_OPACITY": "0.05"},
    "maximum": {"WAVING_LEAVES": "", "WAVING_PLANTS": "",
                "WAVING_VINES": "", "WAVING_FIRE": "", "END_MIN_VISIBILITY_STRENGTH": "0.20", "WAVING_SPEED": "2.0", "WAVING_STRENGTH": "2.0", "MIN_VISIBILITY_STRENGTH": "0.20", "FOG_START": "0.0",
                "FOG_STRENGTH": "1.0", "MOTION_BLUR_STRENGTH": "10.0",
                "WATER_OPACITY": "1.0", "WATER_WAVE_STRENGTH": "2.0",
                "WATER_RIPPLE_STRENGTH": "2.0", "WATER_WAVES": "", "WATER_RIPPLES": ""},
    "unmasked": {"EXCLUDE_HAND_MOTION_BLUR": None},
    "fog_categories_off": {k: None for k in (
        "FOG_DAY", "FOG_NIGHT", "FOG_RAIN", "FOG_NETHER", "FOG_END_DIMENSION",
        "FOG_WATER", "FOG_LAVA", "FOG_POWDER_SNOW", "FOG_BLINDNESS", "FOG_DARKNESS")},
}


def expand(path, overrides=None, stack=()):
    path = path.resolve()
    if path in stack:
        raise ValueError(f"Include cycle: {path}")
    if not path.is_relative_to(SHADERS.resolve()):
        raise ValueError(f"Include outside shaders: {path}")
    source = path.read_text()
    if "\0" in source:
        raise ValueError(f"NUL byte: {path}")
    overrides = overrides or {}
    for name, value in overrides.items():
        pattern = rf"(?m)^[ \t]*(?://[ \t]*)?#define[ \t]+{re.escape(name)}(?:[ \t]+[^\n]*)?$"
        replacement = f"// disabled {name}" if value is None else f"#define {name} {value}"
        source = re.sub(pattern, replacement, source)
        # Shader options can also be const values (shadow resolution/distance).
        if value is not None:
            source = re.sub(rf"(?m)^(const\s+(?:float|int)\s+{name}\s*=)\s*[^;]+;",
                            rf"\g<1> {value};", source)
    def include(match):
        name = match[1]
        target = SHADERS / name.lstrip("/") if name.startswith("/") else path.parent / name
        return "\n" + expand(target, overrides, (*stack, path)) + "\n"
    return re.sub(r'^\s*#include\s+"([^"]+)"\s*$', include, source, flags=re.M)


def entrypoints():
    return sorted(p for p in SHADERS.rglob("*.vsh")
                  if p.parent == SHADERS or p.parent.name in ("world0", "world-1", "world1"))


def validate_iris_directives(source):
    # Iris DispatchingDirectiveHolder parses clear colors separately from GLSL.
    # Scalar splats and expressions compile as GLSL but cannot be parsed here.
    pattern = r"const\s+vec4\s+((?:colortex\d+|shadowcolor\d+)ClearColor)\s*=\s*([^;]+);"
    for name, value in re.findall(pattern, source):
        match = re.fullmatch(r"vec4\s*\(([^()]*)\)", value.strip())
        if not match or len(match[1].split(",")) != 4:
            raise ValueError(f"Iris directive {name} requires four explicit float literals")
        for part in match[1].split(","):
            try:
                float(part.strip().rstrip("fF"))
            except ValueError as exc:
                raise ValueError(f"Iris directive {name} requires float literals: {part}") from exc


def compile_pair(task):
    path, variant, overrides = task
    out = ROOT / ".build" / "glsl" / variant / path.parent.relative_to(SHADERS)
    out.mkdir(parents=True, exist_ok=True)
    sources = []
    for suffix, stage in ((".vsh", ".vert"), (".fsh", ".frag")):
        original = path.with_suffix(suffix)
        target = out / (path.stem + stage)
        source = expand(original, overrides)
        validate_iris_directives(source)
        # Supply only actual Iris environment macros. Format symbols are not GLSL
        # constants and must never be fabricated here to make a broken pack pass.
        source = source.replace("#version 330 compatibility", "#version 330 compatibility\n#define MC_VERSION 260200\n#define IS_IRIS")
        target.write_text(source)
        sources.append(str(target))
    result = subprocess.run(["glslangValidator", "-l", *sources], capture_output=True, text=True)
    if result.returncode:
        return f"{variant}/{path.relative_to(SHADERS)}\n{result.stdout}{result.stderr}"
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--variant", choices=VARIANTS)
    args = parser.parse_args()
    if not shutil.which("glslangValidator"):
        sys.exit("glslangValidator is required (glslang-tools / glslang package).")
    pairs = entrypoints()
    for path in pairs:
        assert path.with_suffix(".fsh").exists(), path
    variants = {args.variant: VARIANTS[args.variant]} if args.variant else VARIANTS
    tasks = [(p, name, overrides) for name, overrides in variants.items() for p in pairs]
    with ThreadPoolExecutor(max_workers=8) as executor:
        failures = [failure for failure in executor.map(compile_pair, tasks) if failure]
    if failures:
        print("\n".join(failures))
        sys.exit(f"FAILED: {len(failures)} / {len(tasks)} program pairs")
    print(f"PASS: {len(tasks)} linked GLSL program pairs ({len(pairs)} pairs x {len(variants)} variants).")


if __name__ == "__main__":
    main()
