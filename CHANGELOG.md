# Changelog

## 0.1.3

- Replace BurntToast blur with the supplied CH Motion V4 implementation unchanged.
- Keep an outer optional hand mask; retain CH Motion's native hand-depth cutoff.
- Set minimum illumination to 0.08; keep sun/moon glare on in both presets.
- Use vanilla biome-blended Nether background/fog colors and a sky brightness floor.
- Adapt Complementary r5.9.3 End stars and textured sky without volumetric beams,
  flashes, ray marching, bloom, or reflections.
- Preserve upstream credits/licenses in the source and release ZIP.

## 0.1.2 — awaiting visual testing

- Fix composite compilation failures for undeclared RGB8, R8 and R11F_G11F_B10F.
  Keep Iris format directives inside a block comment, as required by ShaderDoc.
- Remove fabricated format macros from the standalone compiler environment so
  it can reproduce and catch this failure.
- Add a format-directive regression check. Retain the v0.1.1 clear-color fix.

## 0.1.1 — superseded by 0.1.2

- Fix Iris pack-load crash in DispatchingDirectiveHolder: use four explicit float
  literals for colortex2ClearColor instead of GLSL's scalar vec4 constructor.
- Check Iris clear-color directive syntax independently of GLSL compilation.
- Retain all v0.1.0 feature defaults.

## 0.1.0 — superseded by 0.1.1

- Import Chocapic13 High Performance Toaster and organize shared dimension programs.
- Add independent camera motion blur with CH Motion-compatible controls/defaults.
- Exclude both hands and held items from blur by default, including translucent items.
- Keep hand shadows and environment brightness while removing shader lighting tint.
- Remove dimension lighting casts from entities and retain damage-color overlays.
- Add a neutral minimum illumination floor for enclosed darkness.
- Replace distance, weather, Nether and End height fog with configurable edge fog.
- Add independent water, lava, powder snow, blindness and darkness fog controls.
- Adapt YoFPS transparent water, with configurable opacity/color and optional waves.
- Disable waves and surface ripple distortion by default.
- Add Default/Fast profiles, standalone GLSL validation and deterministic packaging.
- Prepare public source and draft GitHub releases with checksums and upstream credits.
