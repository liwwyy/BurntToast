# BurntToast (Chocapic13' Shaders edit)

An Iris shaderpack based on Chocapic13 High Performance Toaster. Version 0.1.3
adds motion blur, readable darkness, neutral hand and entity lighting, edge-only
fog controls, and transparent water from YoFPS.

## Defaults

| Setting | Default |
| --- | --- |
| Motion blur | On; unchanged CH Motion, strength 5.5, sample setting 8, noise on |
| Exclude hand and both held items from blur | On |
| Remove hand shader tint | On; keeps shadows and environment brightness |
| Remove dimension tint from entities | On |
| Minimum visibility | On; neutral illumination floor 0.08 |
| Fog | Last 10% of render distance; strength 0.25 |
| Water opacity | 0.45 |
| Water waves / ripples | Off / off |
| Shadow resolution / distance | 768 / 48 blocks |
| Sun / Moon Glare | On in both presets |
| Nether sky | Vanilla biome colors; brightness floor 0.08 |
| End sky | Complementary stars and lightweight texture layer |

Every change applies in the Overworld, Nether and End. Unknown dimensions use the
Overworld fallback. Custom dimension-specific atmosphere and Distant Horizons
LOD rendering are not implemented.

## Install

Download `BurntToast_v0.1.3_.Chocapic13_Toaster_edit.zip` from the GitHub release,
place it in your Minecraft `shaderpacks` directory, then select it in Iris.
The build is targeted at Minecraft 26.2 with Iris 1.11.4. Other versions have
not been tested.

Open Shader Pack Settings to change Lighting, MotionBlur, Hand / Entities, Fog,
Water, Shadows, or Atmospherics. Fog has separate controls for day, night,
rain/storms, dimensions, submerged media, blindness, and darkness. Set a category's
strength to zero or switch it off to remove its contribution. The master fog
switch removes all pack fog. Reversed start/end values are safely bounded.

Minimum Visibility adds neutral illumination before texture color and tone
mapping. It keeps unlit surfaces readable without turning the scene gray or
altering black texture pixels. Tune the floor down for darker caves or up for
clearer visibility. Hand tint removal changes lighting color, not texture color;
both hands still respond to brightness and applicable world shadows.

Motion blur now uses the supplied CH Motion V4 source unchanged, including its
native noise, strength response, reprojection, velocity clamp, centered sampling
and hand-depth cutoff. The setting of 8 produces 7 actual taps in the reference.
The hand-exclusion option adds an explicit mask around CH Motion; disabling that
mask does not remove CH Motion's own native close-depth cutoff. Compatibility
Gamma remains at the reference default of 1.0.

Nether background and edge fog use Minecraft's biome-blended fog color, with a
minimum sky brightness of 0.08. End sky keeps Complementary r5.9.3's star pattern,
purple palette and noise texture, using a single lightweight sky layer instead
of volumetric beams, flashes, ray marching or reflection effects.

Choose **Fast** for the native CH sample setting 4 and 512-resolution shadows at
32 blocks. Sun / Moon Glare stays on in both presets. These profiles are quality
presets; use Reset in Iris to restore every individual option.

## Build and checks

Requires Python 3.10+ and `glslangValidator` (`glslang-tools` on Ubuntu).

```sh
python .github/scripts/check.py
python .github/scripts/validate.py
python .github/scripts/package.py
```

The ZIP and SHA-256 checksum are written to `dist/`. Reference ZIPs, build files,
and development tooling are excluded. Release tags must match `VERSION`.
Version tags create draft GitHub releases after validation. Release assets
include the shader ZIP and its SHA-256 checksum.

Standalone compilation and numerical checks do not establish in-game rendering
correctness or FPS gains. See [TESTING.md](TESTING.md) and
[PERFORMANCE.md](PERFORMANCE.md) for validation and optimization details.

## Credits and terms

Chocapic13 provides the base shaderpack. YoFPS, by MLGImposter and NoComment1105,
provides the adapted transparent-water material and wave displacement. CH Motion
by Thompie__ supplies the unchanged blur code. Complementary by EminGT supplies
the adapted End sky/star code and noise texture. Bliss by X0nk is the repository
and optimization reference. Full details are in [CREDITS.txt](CREDITS.txt).

Upstream [modification and sharing terms](LICENSE.md) and the unmodified
Complementary license are retained alongside the credits.
Original code remains credited to its authors. No monetizing download links.
