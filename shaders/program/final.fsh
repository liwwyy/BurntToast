// CH Motion remains byte-for-byte upstream. Hook its texture reads so that
// background blur taps cannot pull hand/held-item colors across the silhouette.
uniform sampler2D colortex2;
bool btHandFootprint(vec2 uv) {
    ivec2 size = textureSize(colortex2, 0);
    ivec2 lo = ivec2(floor(clamp(uv, vec2(0.0), vec2(1.0)) * vec2(size) - 0.5));
    ivec2 hi = size - 1;
    return texelFetch(colortex2, clamp(lo, ivec2(0), hi), 0).r > 0.0
        || texelFetch(colortex2, clamp(lo + ivec2(1, 0), ivec2(0), hi), 0).r > 0.0
        || texelFetch(colortex2, clamp(lo + ivec2(0, 1), ivec2(0), hi), 0).r > 0.0
        || texelFetch(colortex2, clamp(lo + ivec2(1, 1), ivec2(0), hi), 0).r > 0.0;
}
vec4 btMotionTexture(sampler2D source, vec2 uv);
#define texture btMotionTexture
#define Global
#define fsh
#define main CHMotionMain
#include "/program/ch_motion/MotionBlur.glsl"
#undef main
#undef texture
vec4 btMotionTexture(sampler2D source, vec2 uv) {
    #ifdef EXCLUDE_HAND_MOTION_BLUR
        // Cover all four bilinear source texels, including fractional edge taps.
        // Substitute center color to retain CH's original sample count/brightness.
        if (btHandFootprint(uv)) return texture(source, texcoord.st);
    #endif
    return texture(source, uv);
}
void main() {
    #ifdef EXCLUDE_HAND_MOTION_BLUR
        if (btHandFootprint(texcoord.st)) {
            vec3 color = texture(colortex0, texcoord.st).rgb;
            gl_FragData[0] = vec4(pow(max(color, 0.0), vec3(VANILLA_GAMMA)), 1.0);
            return;
        }
    #endif
    CHMotionMain();
}
