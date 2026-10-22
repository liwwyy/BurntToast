# BurntToast (Chocapic13' Shaders edit)

An Iris shaderpack based on Chocapic13 High Performance Toaster. Version 0.1.1
adds motion blur, readable darkness, neutral hand and entity lighting, edge-only
fog controls, and transparent water from YoFPS.

## Defaults

| Setting | Default |
| --- | --- |
| Motion blur | On; strength 5.5, 8 samples, noise on |
| Exclude hand and both held items from blur | On |
| Remove hand shader tint | On; keeps shadows and environment brightness |
| Remove dimension tint from entities | On |
| Minimum visibility | On; neutral illumination floor 0.04 |
| Fog | Last 10% of render distance; strength 0.25 |
| Water opacity | 0.45 |
| Water waves / ripples | Off / off |
| Shadow resolution / distance | 768 / 48 blocks |

Every change applies in the Overworld, Nether and End. Unknown dimensions use the
Overworld fallback. Custom dimension-specific atmosphere and Distant Horizons
LOD rendering are not implemented.

## Install

Download `BurntToast_v0.1.1_.Chocapic13_Toaster_edit.zip` from a GitHub release,
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

Motion blur uses original BurntToast code with CH Motion-compatible settings.
It blurs camera motion, not independently moving entities. Compatibility Gamma
is an advanced post-blur control; leave it at 1.0 for the intended appearance.

Choose **Fast** to use 4 blur samples, 512-resolution shadows at 32 blocks, and no
sun glare. **Default** retains Toaster shadow/glare quality. These profiles are
quality presets; use Reset in Iris to restore every individual option.

## Build and checks

Requires Python 3.10+ and `glslangValidator` (`glslang-tools` on Ubuntu).

```sh
python .github/scripts/check.py
python .github/scripts/validate.py
python .github/scripts/package.py
```

The ZIP and SHA-256 checksum are written to `dist/`. Reference ZIPs, build files,
and development tooling are excluded. Release tags must match `VERSION`.
Tags such as `v0.1.1` create **draft** GitHub releases; publish after visual testing.

Standalone compilation and numerical checks do not establish in-game rendering
correctness or FPS gains. See [TESTING.md](TESTING.md) and
[PERFORMANCE.md](PERFORMANCE.md) for validation and optimization details.

## Credits and terms

Chocapic13 provides the base shaderpack. YoFPS, by MLGImposter and NoComment1105,
provides the adapted transparent-water material and wave displacement. CH Motion
by Thompie__ is the settings/behavior reference. Bliss by X0nk is the repository
and optimization reference. Full details are in [CREDITS.txt](CREDITS.txt).

Redistribution follows the upstream [modification and sharing terms](LICENSE.md).
Original code remains credited to its authors. No monetizing download links.
