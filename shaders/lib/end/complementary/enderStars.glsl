// Adapted from Complementary Reimagined r5.9.3 by EminGT.
// See licenses/Complementary-License.txt.
float GetEnderStarNoise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 4.1414))) * 43758.54953);
}

vec3 GetEnderStars(vec3 viewPos, float VdotU) {
    vec3 wpos = normalize(mat3(gbufferModelViewInverse) * viewPos);

    vec3 starCoord = 0.65 * wpos / (abs(wpos.y) + length(wpos.xz));
    vec2 starCoord2 = starCoord.xz * 0.5;
    if (VdotU < 0.0) starCoord2 += 100.0;
    float starFactor = 1024.0;
    starCoord2 = floor(starCoord2 * starFactor) / starFactor;

    float star = 1.0;
    star *= GetEnderStarNoise(starCoord2.xy);
    star *= GetEnderStarNoise(starCoord2.xy+0.1);
    star *= GetEnderStarNoise(starCoord2.xy+0.23);
    star = max(star - 0.7, 0.0);
    star *= star;

    vec3 enderStars = star * endSkyColor * 3000.0;

    // Uniform attenuation avoids the old circular dark caps at both poles.
    enderStars *= 0.065;

    return enderStars * END_STAR_INTENSITY;
}
