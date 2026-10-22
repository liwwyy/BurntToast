// Toaster tone mapping, with BurntToast edge fog.
in vec4 texcoord;
flat in vec4 fogColor;
flat in vec3 flareColor;
uniform sampler2D depthtex0;
uniform sampler2D colortex1;
uniform int isEyeInWater;
uniform float rainStrength;
uniform float sunIntensity;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
#include "/lib/buffers.glsl"
#include "/lib/color_transforms.glsl"
#include "/lib/fog.glsl"
vec3 btUnrealTonemap(vec3 x) {
    return x / (0.98135426889 * x + 0.154 * 0.98135426889);
}
void main() {
    /* DRAWBUFFERS:0 */
    vec3 scene = texture2D(colortex1, texcoord.xy).rgb;
    float depth = texture2D(depthtex0, texcoord.xy).r;
    if (depth < 1.0 || isEyeInWater != 0) {
        vec4 view = gbufferProjectionInverse * vec4(texcoord.xy * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
        vec3 position = view.xyz / max(abs(view.w), 0.00001);
        scene = btFog(scene, fogColor.rgb, length((mat3(gbufferModelViewInverse) * position).xz), texcoord.xy,
                      1.0 - clamp(sunIntensity * 5.0, 0.0, 1.0));
    }
    #ifdef SUN_GLARE
        if (texture2D(colortex2, texcoord.xy).r == 0.0)
            scene += flareColor / (1.0 + dot(texcoord.zw, texcoord.zw));
    #endif
    scene = max(scene * EXPOSURE_MULTIPLIER, vec3(0.0));
    #ifdef TONEMAP_ACES
        vec3 mapped = ACESFilm(scene);
    #else
        vec3 mapped = btUnrealTonemap(scene);
    #endif
    float dither = fract(52.9829189 * fract(dot(gl_FragCoord.xy, vec2(0.06711056, 0.00583715))));
    gl_FragData[0] = vec4(mapped + dither / 256.0, 1.0);
}
