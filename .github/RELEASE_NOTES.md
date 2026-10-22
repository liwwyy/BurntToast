BurntToast (Chocapic13' Shaders edit) v0.1.2

Fixes composite compilation errors for undeclared `RGB8`, `R8`, and
`R11F_G11F_B10F`. Format directives now use the block-comment syntax required
by Iris ShaderDoc. Validation no longer fabricates these missing GLSL constants
and reproduces the original failure before the fix. Includes the v0.1.1
four-value clear-color directive fix.

Also checked the format and clear-color metadata using the directive parser
from the installed Iris 1.11.4 JAR, without starting Minecraft or using a GUI.

Includes camera motion blur with CH Motion-compatible settings, hand/held-item blur
exclusion, neutral hand/entity lighting, a minimum visibility floor, configurable
edge-only fog, and YoFPS-derived transparent water. Waves and ripples default off.

Defaults preserve Toaster's 768-resolution shadows at 48 blocks. The optional
Fast preset lowers blur samples/shadows and disables sun glare.

Target: Minecraft 26.2 with Iris 1.11.4. Automated contract checks and standalone
GLSL compilation/linking run in CI. In-game visual testing and FPS measurement
are pending; this release remains a draft until the user's visual acceptance.

Install the attached ZIP directly in `shaderpacks`. Its `.sha256` file contains
the checksum. See README.md, TESTING.md, PERFORMANCE.md and CREDITS.txt in the repo.

Credits: Chocapic13 (base), MLGImposter / NoComment1105 (YoFPS water), Thompie__
(CH Motion settings/behavior reference), X0nk / Bliss contributors (structure
and optimization reference). Motion blur is independently implemented; CH Motion
and Bliss code are not redistributed. Upstream modification/sharing terms apply.
