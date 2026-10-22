BurntToast (Chocapic13' Shaders edit) v0.1.3

- Replace the previous blur with the supplied CH Motion V4 implementation,
  copied unchanged, including its native hand-depth cutoff and sampling.
- Set minimum illumination to 0.08.
- Enable sun/moon glare in both Default and Fast presets.
- Use vanilla biome-blended Nether sky/fog colors with a sky brightness floor.
- Add Complementary-derived End stars, palette and a lightweight texture layer,
  without volumetric beams, flashes, ray marching, bloom or reflections.

Install `BurntToast_v0.1.3_.Chocapic13_Toaster_edit.zip` directly in shaderpacks.
The accompanying `.sha256` file contains its checksum.

Target: Minecraft 26.2 / Iris 1.11.4. Validation covers 12 pack checks, 704
standalone GLSL program-pair compile/link checks, and the directive parser from
the installed Iris 1.11.4 JAR. In-game visuals and FPS remain unverified.

The hand-exclusion option adds an explicit hand mask. Disabling it does not
remove CH Motion's native close-depth cutoff. Its sample setting 8 uses 7 taps,
matching the supplied reference unchanged.

Credits: Chocapic13 (base), MLGImposter / NoComment1105 (YoFPS water), Thompie__
(CH Motion), EminGT / Complementary Development (End sky code and noise texture),
and X0nk / Bliss contributors (structure/optimization reference).
See CREDITS.txt, LICENSE.md and licenses/Complementary-License.txt for provenance
and retained upstream terms.
