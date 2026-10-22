#ifndef BURNTTOAST_END_SKY
#define BURNTTOAST_END_SKY
// Palette, star field and noise-layer construction adapted from Complementary
// Reimagined r5.9.3 by EminGT. See the preserved upstream license.
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
        vec3 weights = pow(abs(worldDirection), vec3(4.0));
        weights /= weights.x + weights.y + weights.z;
        vec2 wind = vec2(frameTimeCounter * 0.001);
        float noise = dot(weights, vec3(
            btEndSkyNoise(worldDirection.yz * 4.0, wind),
            btEndSkyNoise(worldDirection.zx * 4.0, wind),
            btEndSkyNoise(worldDirection.xy * 4.0, wind)));
        float textureLayer = noise * noise;
        sky *= max(0.0, 1.0 + (textureLayer - 0.45) * END_SKY_TEXTURE_STRENGTH);
    #endif
    sky *= END_SKY_BRIGHTNESS;
    #ifdef END_STARS
        sky += GetEnderStars(viewDirection, worldDirection.y);
    #endif
    return max(sky, vec3(0.0));
}
#endif
