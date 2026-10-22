# Testing BurntToast 0.1.3

## Automated checks

Run `python .github/scripts/check.py` for include paths, option discovery and
defaults, Iris clear-color and commented format directive syntax, hand-mask
routing, version consistency, reproducible ZIP layout, and
CPU reference checks for fog boundaries, blur energy and minimum illumination.

Run `python .github/scripts/validate.py` for standalone GLSL 330 compatibility
compilation and vertex/fragment linking: 88 program pairs across eight variants
(704 pair validations). Variants cover default, disabled features, enabled water
effects/ACES/gamma, Fast, minimum/maximum values, hand exclusion off, and all fog
categories off. Includes are expanded and only MC_VERSION / IS_IRIS environment
macros are supplied; format symbols are not injected. This is not Iris's actual
shader transformation pipeline.

An optional check uses the real directive parser from an installed Iris JAR,
without starting Minecraft or creating an OpenGL context. With a matching JDK
installed, run:

```sh
python .github/scripts/check_iris.py --iris-jar /path/to/iris.jar --libraries /path/to/PrismLauncher/libraries
```

This checks all four composite entry points with Iris's own format, clear-flag
and four-component clear-color handlers. It passed locally with Iris 1.11.4.

Compilation and CPU checks do not establish visual correctness, compatibility
with every resource pack/mod, or GPU performance.

## User visual checks

1. Select the installed ZIP in Iris. With debug mode enabled, reload shaders and
   check for errors. Test the default preset before changing settings.
2. In each dimension, inspect both hands, a shield/offhand item, a translucent
   held block, a map and a glinting item. Turn and move quickly: hands should stay
   sharp without smearing into the background. Hide/show the hand to check that
   old mask pixels do not remain. CH Motion retains its native close-depth hand cutoff even when the additional
   hand mask is disabled. Compare blur directly with the supplied CH Motion pack.
3. Move between sunlight, shadows, caves and local lights. Hand brightness should
   follow the environment; enabling tint removal must not make it fullbright.
   Check neutral entity colors in the Nether/End and red damage flashes.
4. Box the player into a completely unlit room. Nearby non-black texture detail
   should remain readable. Try floors of 0.04, 0.08 and 0.10 to calibrate the
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

## Local sky checks

- In the Nether, move between wastes, crimson/warped forests, soul sand valleys
  and basalt deltas. Background colors should follow vanilla biome blending,
  with a faint brightness floor even in dark biomes. Test fog on and off.
- In the End, check that stars and the textured purple background are stable
  when turning. Toggle stars and sky texture separately. There should be no
  volumetric beams or flashes.

## Release gate

The current v0.1.3 build is local-only. Do not push or publish its borrowed
CH Motion / Complementary integration until the user resolves publication.
The public repository remains at v0.1.2.
Retain any limitations and measured performance results in the release notes.
