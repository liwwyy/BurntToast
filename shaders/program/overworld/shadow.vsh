
#include "/lib/shadow_param.glsl"

out vec2 texcoord;
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowModelView;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
#include "/lib/waving.glsl"

void main() {

	vec4 world = shadowModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
    world.xyz += btVegetationOffset(world.xyz + cameraPosition, mc_Entity.x,
        gl_MultiTexCoord0.t < mc_midTexCoord.t, frameTimeCounter);
    gl_Position = BiasShadowProjection(gl_ProjectionMatrix * shadowModelView * world);
	gl_Position.z /= 3.0;


	texcoord = gl_MultiTexCoord0.xy;
}
