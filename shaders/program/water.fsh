/*
!! DO NOT REMOVE !!
Chocapic13 lighting; transparent water material adapted from YoFPS.
YoFPS: MLGImposter / NoComment1105. See CREDITS.txt and LICENSE.md.
*/
#include "/lib/surface.glsl"
in vec4 lmtexcoord;
in vec4 color;
in vec4 shadowPos;
in vec3 btWaterPosition;
flat in float btIsWater;
uniform sampler2D texture;
uniform float frameTimeCounter;
#ifdef BT_OVERWORLD
    #include "/lib/shadow_param.glsl"
    uniform sampler2D gaux1;
    uniform sampler2DShadow shadow;
    uniform vec4 lightCol;
    uniform vec2 texelSize;
#endif
vec3 toLinear(vec3 sRGB) {
    return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}
void main() {
    /* DRAWBUFFERS:1 */
    vec2 uv = lmtexcoord.xy;
    #ifdef WATER_RIPPLES
        if (btIsWater > 0.5)
            uv += sin(btWaterPosition.xz * 2.0 + frameTimeCounter * vec2(1.3, 1.1)) * 0.002 * WATER_RIPPLE_STRENGTH;
    #endif
    vec4 texel = texture2D(texture, uv) * color;
    #ifdef TRANSPARENT_WATER
        if (btIsWater > 0.5) {
            texel.rgb = vec3(WATER_R, WATER_G, WATER_B) * length(texel.rgb) * color.rgb;
            texel.a = WATER_OPACITY * color.a;
        }
    #endif
    if (texel.a <= 0.0) discard;
    vec3 illumination;
    #ifdef BT_OVERWORLD
        float sunlight = shadowPos.w / 255.0;
        if (sunlight > 0.0001 && shadowPos.x < 1e10) {
            float distortion = calcDistort(shadowPos.xy);
            vec2 coordinate = shadowPos.xy / distortion;
            if (max(abs(coordinate.x), abs(coordinate.y)) < 1.0 - 1.5 / float(shadowMapResolution)) {
                float bias = 0.0004 * 512.0 / float(shadowMapResolution) * shadowDistance / 45.0 * distortion / sunlight;
                vec3 projected = vec3(coordinate, shadowPos.z) * vec3(0.5, 0.5, 0.5 / 3.0) + vec3(0.5, 0.5, 0.5 - bias);
                sunlight *= shadow2D(shadow, projected).r;
            }
        }
        illumination = lightCol.rgb * sunlight + texture2D(gaux1, lmtexcoord.zw * texelSize).rgb;
        gl_FragData[0] = vec4(btSurfaceLight(illumination) * toLinear(texel.rgb), texel.a);
    #else
        #ifdef BT_END
            illumination = btSurfaceLight(shadowPos.xyz * 1.275);
            gl_FragData[0] = vec4(illumination * toLinear(texel.rgb) * (100.0 / 1.5), texel.a);
        #else
            illumination = btSurfaceLight(shadowPos.xyz * 0.85);
            gl_FragData[0] = vec4(illumination * toLinear(texel.rgb) * 100.0, texel.a);
        #endif
    #endif
}
