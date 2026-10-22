// CH Motion source and vertex programs are copied byte-for-byte from the
// supplied archive. Only this outer hand-mask adapter is BurntToast code.
#define Global
#define fsh
#define main CHMotionMain
#include "/program/ch_motion/MotionBlur.glsl"
#undef main
uniform sampler2D colortex2;
void main() {
    #ifdef EXCLUDE_HAND_MOTION_BLUR
        if (texture(colortex2, texcoord.st).r > 0.0) {
            vec3 color = texture(colortex0, texcoord.st).rgb;
            gl_FragData[0] = vec4(pow(max(color, 0.0), vec3(VANILLA_GAMMA)), 1.0);
            return;
        }
    #endif
    // Preserves CH Motion's native depth cutoff and entire blur kernel unchanged.
    CHMotionMain();
}
