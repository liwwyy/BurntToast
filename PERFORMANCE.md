# Performance notes

BurntToast keeps Toaster's forward rendering and compact lighting/sky lookup
computation. Default shadows stay at 768 resolution and 48 blocks. Motion blur
adds work compared with Toaster; a net FPS increase is not promised.

## Community edits reviewed

| Source | Finding | BurntToast decision |
| --- | --- | --- |
| [YoFPS](https://github.com/NoComment1105/YoFPS-Chocapic13-edit/blob/main/shaders/shaders.properties) | Low/Normal/High profiles compile optional effects out. | Add Default/Fast profiles; compile water displacement and ripple distortion out by default. |
| Supplied YoFPS High reference | Clear-water material uses color `(0.1, 0.75, 0.6)` and opacity `0.45`; waves are optional. Its larger final pass also computes water normals and reflections. | Port material and displacement only. Keep the lightweight Toaster pipeline; no reflection/refraction pipeline is added. |
| [Bliss final pass](https://github.com/X0nk/Bliss-Shader/blob/Stable/shaders/dimensions/final.fsh) | Motion blur uses four color samples and clamps sample coordinates at screen edges. | Offer four samples in Fast; retain the requested eight in Default. Clamp samples and normalize the number actually accepted. No Bliss code is copied. |
| [Bliss program settings](https://github.com/X0nk/Bliss-Shader/blob/Stable/shaders/shaders.properties) | Optional programs and translucent blending are configured explicitly. | Use explicit opaque/translucent hand programs and per-attachment mask blending. Avoid adding intermediate post-process targets. |

Upstream links describe the reviewed revision and may change. The supplied
reference ZIPs were used for the actual Toaster and YoFPS ports; their hashes are
recorded in `REFERENCE_SOURCES.md`.

## Applied changes

- Run blur in the final screen-output pass rather than adding a blur composite
  and another full-frame color write. Precompute combined camera matrices in
  the final vertex program. Skip the color-sampling loop when the camera is still.
- Use a compact R8 hand mask. A mask is more reliable than assuming every pixel
  closer than a fixed depth threshold belongs to a hand; it costs an attachment
  and mask reads, including sample rejection around silhouettes.
- Remove duplicate glare sample-position arithmetic. Disabling glare compiles
  its 1000-iteration visibility loop out. Default retains 1000 samples so partial
  sun occlusion is not deliberately degraded.
- Replace exponential/height fog with one bounded edge ramp. Medium fog replaces
  atmospheric fog instead of stacking multiple full-strength layers.
- Remove unused imported helpers, obsolete missing texture bindings, and a
  conflicting weather shadow-resolution declaration. Removing unused source
  mainly improves maintenance and package size, not runtime FPS.
- Use packed floating-point scene/lookup targets and an RGB8 display target;
  retain the original compact lookup viewport and avoid needless mask persistence.

## Optional savings

1. Use **Fast**: four blur samples; 512-resolution shadows; 32-block shadow range;
   glare off. These are visual tradeoffs, not equivalent-quality optimizations.
2. Lower Motion Blur Samples independently if you want to keep default shadows.
3. Disable Sun / Moon Glare or lower its samples to 64–128. Check partial sun
   occlusion for flicker or visible sampling differences.
4. Keep Water Waves and Water Surface Ripples off. Their disabled branches have
   no wave/ripple math in the compiled program.
5. Disable motion blur entirely to compare the rest of BurntToast with Toaster.

Further candidates, deferred until profiling: a fixed-size lookup attachment
with updated sampling coordinates, reduced glare sampling with temporal
stabilization, and more aggressive shadow culling. Toaster already limits the
lookup draw to roughly 276 by 258 pixels, so treating it as an expensive
full-screen sky calculation would be an incorrect optimization premise.

## Measure on the target system

Target discovered from the instance log: Minecraft 26.2, Iris 1.11.4, RX 550,
i5-3570K, Mesa OpenGL 4.6. No FPS measurements have been taken for this build.

For a useful comparison, keep resolution, render distance, mods, resource pack,
world position, weather, time, frame cap and VSync unchanged. Warm up each pack,
then compare both stationary and turning-camera frame times in the Overworld,
Nether, an entity-heavy scene and a water scene. Record Toaster, BurntToast
Default, BurntToast with blur off, and Fast separately. CPU-limited scenes may
show little FPS improvement from GPU optimizations.
