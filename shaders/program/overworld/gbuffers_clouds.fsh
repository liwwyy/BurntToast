/* DRAWBUFFERS:1 */
in vec4 color;
in vec3 texcoord;
uniform sampler2D gaux1;
uniform sampler2D texture;
uniform vec2 texelSize;
uniform vec4 lightCol;
uniform float rainStrength;
uniform float exposure;
void main() {
  vec3 lightCol = texelFetch(gaux1, ivec2(0, 16), 0).rgb*2.0 + lightCol.rgb;
  gl_FragData[0] = vec4(lightCol, 1.0) * texture2D(texture, texcoord.xy) * vec4(vec3(texcoord.z), 1.0);
}
