// Detailed sky is evaluated once in composite for sky pixels only.
void main() {
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = vec4(vec3(0.095, 0.07, 0.15) * 1.65 * END_SKY_BRIGHTNESS * (100.0 / 1.5), 1.0);
}
