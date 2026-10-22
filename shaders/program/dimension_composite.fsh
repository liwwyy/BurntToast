// Retains Toaster's dimension-specific ACES curve and exposure scale.
in vec2 texcoord;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform int isEyeInWater;
uniform float rainStrength;
#include "/lib/buffers.glsl"
#include "/lib/fog.glsl"
vec3 btDimensionTonemap(vec3 x) {
    vec3 film = (x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14);
    return pow(max(film, vec3(0.0)), vec3(1.0 / 2.233333333));
}
void main() {
    /* DRAWBUFFERS:0 */
    vec3 scene = texture2D(colortex1, texcoord).rgb / 100.0;
    float depth = texture2D(depthtex0, texcoord).r;
    vec4 view = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec3 position = view.xyz / max(abs(view.w), 0.00001);
    #ifdef BT_NETHER
        vec3 atmosphere = vec3(1.4, 0.22, 0.0) * 0.4;
    #else
        vec3 atmosphere = pow(vec3(138.0, 120.0, 180.0) / 255.0, vec3(2.2)) * 0.03;
    #endif
    scene = btFog(scene, atmosphere, length((mat3(gbufferModelViewInverse) * position).xz), texcoord, 0.0);
    #ifdef BT_END
        scene *= 1.5;
    #endif
    vec3 mapped = btDimensionTonemap(max(scene * EXPOSURE_MULTIPLIER, vec3(0.0)));
    float dither = fract(52.9829189 * fract(dot(gl_FragCoord.xy, vec2(0.06711056, 0.00583715))));
    gl_FragData[0] = vec4(mapped + dither / 256.0, 1.0);
}
