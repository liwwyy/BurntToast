BurntToast (Chocapic13' Shaders edit) v0.1.0

Adds camera motion blur with CH Motion-compatible settings, hand/held-item blur
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
