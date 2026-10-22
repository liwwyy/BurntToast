# Testing BurntToast 0.1.1

## Automated checks

Run `python .github/scripts/check.py` for include paths, option discovery and
defaults, Iris clear-color directive syntax, hand-mask routing, version consistency, reproducible ZIP layout, and
CPU reference checks for fog boundaries, blur energy and minimum illumination.

Run `python .github/scripts/validate.py` for standalone GLSL 330 compatibility
compilation and vertex/fragment linking: 88 program pairs across eight variants
(704 pair validations). Variants cover default, disabled features, enabled water
effects/ACES/gamma, Fast, minimum/maximum values, hand exclusion off, and all fog
categories off. Includes and OpenGL format macros are expanded for glslang;
this is not Iris's actual shader transformation pipeline.

Compilation and CPU checks do not establish visual correctness, compatibility
with every resource pack/mod, or GPU performance.

## User visual checks

1. Select the installed ZIP in Iris. With debug mode enabled, reload shaders and
   check for errors. Test the default preset before changing settings.
2. In each dimension, inspect both hands, a shield/offhand item, a translucent
   held block, a map and a glinting item. Turn and move quickly: hands should stay
   sharp without smearing into the background. Hide/show the hand to check that
   old mask pixels do not remain. Switch hand exclusion off to compare.
3. Move between sunlight, shadows, caves and local lights. Hand brightness should
   follow the environment; enabling tint removal must not make it fullbright.
   Check neutral entity colors in the Nether/End and red damage flashes.
4. Box the player into a completely unlit room. Nearby non-black texture detail
   should remain readable. Try floors of 0.02, 0.04 and 0.06 to calibrate the
   default. Check that bright daylight, night sky and torches remain reasonable.
5. At several render distances, check day/night, rain/thunder, Nether and End
   fog. It should begin near 90% of render distance. Test each category off and
   the master fog switch off, including water, lava, powder snow, blindness and
   darkness. Vanilla fire, suffocation, powder-snow texture overlays and status
   gameplay effects are separate from distance fog and are not removed.
6. Check stationary clear water from above and below. Compare opacity settings,
   and toggle waves/ripples separately. Glass, stained glass, ice and other
   translucent blocks should retain normal textures and alpha.
7. Test teleporting, dimension changes, resize/fullscreen changes, and shader
   reloads. Watch for one-frame blur streaks, black output or lost hand alpha.
8. Compare Default/Fast performance using the matched scenes in PERFORMANCE.md.

No GUI automation, screenshots, or graphical testing are performed by the agent.
After your reload, the useful diagnostics are the instance's `logs/latest.log`
and Iris's `patched_shaders` directory. These can be inspected without GUI input.

## Release gate

The public repository and draft v0.1.1 release are prepared after automated
checks. Publish the draft only after the user confirms the visual checks pass.
Retain any limitations and measured performance results in the release notes.
