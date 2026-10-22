# Changelog

## 0.1.1 — awaiting visual testing

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
