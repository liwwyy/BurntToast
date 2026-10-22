#ifndef BURNTTOAST_NETHER_SKY
#define BURNTTOAST_NETHER_SKY
// Vanilla supplies the current, biome-blended Nether atmosphere as fogColor.
// Lift only its luminance floor; preserve its hue rather than hardcoding red.
vec3 btNetherSkyDisplay(vec3 vanillaColor) {
    vec3 color = max(vanillaColor, vec3(0.0));
    float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
    if (luminance < 0.00001) return vec3(NETHER_SKY_MIN_BRIGHTNESS);
    return clamp(color * max(1.0, NETHER_SKY_MIN_BRIGHTNESS / luminance), 0.0, 1.0);
}
vec3 btNetherSkyRadiance(vec3 vanillaColor) {
    // Invert the dimension ACES curve so fog/sky retain vanilla display colors.
    vec3 encoded = pow(clamp(btNetherSkyDisplay(vanillaColor), 0.0, 0.99), vec3(2.233333333));
    vec3 a = 2.43 * encoded - 2.51;
    vec3 b = 0.59 * encoded - 0.03;
    vec3 c = 0.14 * encoded;
    return 2.0 * c / max(sqrt(max(b * b - 4.0 * a * c, vec3(0.0))) - b, vec3(0.000001));
}
#endif
