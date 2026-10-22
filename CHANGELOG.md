# Changelog

## 0.1.5 — awaiting visual testing

- Disable leaves, plants, vines and fire waving by default in both profiles.
  Keep all animation controls available with speed/strength defaults of 1.0.
- Keep water waves and ripples disabled by default.
- Document that Sildur has no explicit Litematica patch in the supplied archive,
  and that the same blurry schematic textures occur with Sildur. Upstream Iris
  issue #2974 has no posted fix; no renderer compatibility workaround is claimed.
- Retain the v0.1.4 hand-edge blur and End lighting/sky fixes.

## 0.1.4 — awaiting visual testing

- Prevent background motion-blur taps from sampling hands or held items, including
  all four texels in a filtered edge footprint. Keep the CH Motion source unchanged.
- Give End surfaces a separate minimum illumination default of 0.0; keep 0.08
  as the Overworld/Nether default.
- Remove polar star attenuation and use continuous triplanar End sky texture mapping
  to eliminate the former circular caps and hemispheric texture seam.
- Add Sildur Enhanced Default v1.20 Fancy foliage/fire waving, with category, speed
  and strength controls, modern block mappings, and matching Overworld shadows.
- Document the upstream Iris/MaLiLib texture-atlas issue affecting Litematica overlays.

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
