#ifndef BURNTTOAST_END_SKY
#define BURNTTOAST_END_SKY
// Palette, star field and noise-layer construction adapted from Complementary
// Reimagined r5.9.3 by EminGT. Local build: see the preserved upstream license.
uniform sampler2D btEndNoise;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
const vec3 endSkyColor = vec3(0.095, 0.07, 0.15) * 1.65;
float pow2(float value) { return value * value; }
#include "/lib/end/complementary/enderStars.glsl"

// Complementary's three-scale BeamNoise, used as one sky-surface layer.
// No ray marching, volumetric beams, flashes, shadows, bloom or reflections.
float btEndSkyNoise(vec2 planeCoord, vec2 wind) {
    float noise = textureLod(btEndNoise, planeCoord * 0.175 - wind, 0.0).b * 0.5;
    noise += textureLod(btEndNoise, planeCoord * 0.04375 + wind * 0.5, 0.0).b * 2.0;
    noise += textureLod(btEndNoise, planeCoord * 0.7 - wind, 0.0).b * 0.5;
    return noise / 3.0;
}
vec3 btEndSky(vec3 viewDirection) {
    vec3 worldDirection = normalize(mat3(gbufferModelViewInverse) * viewDirection);
    vec3 sky = endSkyColor;
    #ifdef END_SKY_TEXTURE
        vec2 plane = worldDirection.xz / (abs(worldDirection.y) + length(worldDirection.xz));
        if (worldDirection.y < 0.0) plane += vec2(2.0);
        vec2 wind = vec2(frameTimeCounter * 0.001);
        float noise = btEndSkyNoise(plane * 4.0, wind);
        float fireNoise = textureLod(btEndNoise, abs(plane * 0.4) - wind, 0.0).b;
        float textureLayer = noise * noise * 0.7 + 0.3 * fireNoise;
        sky *= max(0.0, 1.0 + (textureLayer - 0.45) * END_SKY_TEXTURE_STRENGTH);
    #endif
    sky *= END_SKY_BRIGHTNESS;
    #ifdef END_STARS
        sky += GetEnderStars(viewDirection, worldDirection.y);
    #endif
    return max(sky, vec3(0.0));
}
#endif
