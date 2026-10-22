# BurntToast (Chocapic13' Shaders edit)

An Iris shaderpack based on Chocapic13 High Performance Toaster. Version 0.1.5
adds motion blur, readable darkness, neutral hand and entity lighting, edge-only
fog controls, and transparent water from YoFPS.

## Defaults

| Setting | Default |
| --- | --- |
| Motion blur | On; unchanged CH Motion, strength 5.5, sample setting 8, noise on |
| Exclude hand and both held items from blur | On |
| Remove hand shader tint | On; keeps shadows and environment brightness |
| Remove dimension tint from entities | On |
| Minimum visibility | On; Overworld/Nether 0.08, End 0.0 |
| Fog | Last 10% of render distance; strength 0.25 |
| Water opacity | 0.45 |
| Water waves / ripples | Off / off |
| Shadow resolution / distance | 768 / 48 blocks |
| Sun / Moon Glare | On in both presets |
| Nether sky | Vanilla biome colors; brightness floor 0.08 |
| End sky | Complementary stars and continuous texture layer; no dark polar caps |
| Vegetation waving | Leaves, plants, vines and fire off; optional speed/strength 1.0 |

Every change applies in the Overworld, Nether and End. Unknown dimensions use the
Overworld fallback. Custom dimension-specific atmosphere and Distant Horizons
LOD rendering are not implemented.

## Install

Download `BurntToast_v0.1.5_.Chocapic13_Toaster_edit.zip` from the GitHub release,
place it in your Minecraft `shaderpacks` directory, then select it in Iris.
The build is targeted at Minecraft 26.2 with Iris 1.11.4. Other versions have
not been tested.

Open Shader Pack Settings to change Lighting, MotionBlur, Hand / Entities, Fog,
Water, Shadows, Atmospherics, or Vegetation. Fog has separate controls for day, night,
rain/storms, dimensions, submerged media, blindness, and darkness. Set a category's
strength to zero or switch it off to remove its contribution. The master fog
switch removes all pack fog. Reversed start/end values are safely bounded.

Minimum Visibility adds neutral illumination before texture color and tone
mapping. It keeps unlit surfaces readable without turning the scene gray or
altering black texture pixels. Tune the floor down for darker caves or up for
clearer visibility. End Minimum Illumination has its own default of 0.0, independent
of the Overworld/Nether slider. Hand tint removal changes lighting color, not texture color;
both hands still respond to brightness and applicable world shadows.

Motion blur now uses the supplied CH Motion V4 source unchanged, including its
native noise, strength response, reprojection, velocity clamp, centered sampling
and hand-depth cutoff. The setting of 8 produces 7 actual taps in the reference.
The hand-exclusion option protects both hand pixels and background blur taps whose
bilinear texture footprint touches the hand mask. Masked taps use the current
pixel color, so hand colors cannot trail into the background. Disabling that
mask does not remove CH Motion's own native close-depth cutoff. Compatibility
Gamma remains at the reference default of 1.0.

Nether background and edge fog use Minecraft's biome-blended fog color, with a
minimum sky brightness of 0.08. End sky keeps Complementary r5.9.3's star pattern,
purple palette and noise texture, with uniform star attenuation and continuous
triplanar texture mapping instead
of volumetric beams, flashes, ray marching or reflection effects.

Choose **Fast** for the native CH sample setting 4 and 512-resolution shadows at
32 blocks. Sun / Moon Glare stays on in both presets. These profiles are quality
presets; use Reset in Iris to restore every individual option.

## Vegetation and schematic overlays

Vegetation waving is disabled by default in both Default and Fast profiles.
Vegetation controls can enable Sildur Enhanced Default v1.20 Fancy-derived waving for
leaves, grass/flowers/crops, vines and fire separately, plus speed and strength.
Plant bases stay anchored; tall plants use half-specific block mappings. The
Overworld shadow pass applies the same world-space displacement. Water retains
its existing independent wave/ripple controls, both off by default. Lantern and
lava movement are not included.

Litematica ghost blocks with low-resolution textures match the upstream
[Iris/MaLiLib atlas-size issue #2974](https://github.com/IrisShaders/Iris/issues/2974).
Inspection of the supplied Sildur Enhanced Default archive found no explicit
Litematica compatibility patch; the same blurry ghost textures were reported
with that pack as well. Issue #2974 proposes Iris support for MaLiLib's `ChunkFix`
uniform buffer, which supplies texture-atlas dimensions. As checked for v0.1.5,
it has no posted fix or workaround; its only comment assigns a developer.
This version makes no shaderpack compatibility claim or changes to installed
mods or Litematica settings. The [Litematica maintainer](https://modrinth.com/mod/litematica)
recommends disabling shaders while using schematic rendering on Minecraft 1.21.3
and later.

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
