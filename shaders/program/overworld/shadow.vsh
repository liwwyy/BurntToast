
#include "/lib/shadow_param.glsl"

out vec2 texcoord;

void main() {

	gl_Position = BiasShadowProjection(ftransform());
	gl_Position.z /= 3.0;


	texcoord = gl_MultiTexCoord0.xy;
}
