uniform vec3 fogColor;
#include "/lib/nether/sky.glsl"
void main() {
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = vec4(btNetherSkyRadiance(fogColor) * 100.0, 1.0);
}
