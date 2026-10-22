
out vec4 color;
out vec3 texcoord;

void main() {
	color = vec4(1.);
	gl_Position = ftransform();
	texcoord.xy = gl_MultiTexCoord0.xy;
	texcoord.z = 	normalize(gl_NormalMatrix * gl_Normal).y * 0.03+0.14;
}
