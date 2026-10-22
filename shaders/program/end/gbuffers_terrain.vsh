
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

out vec4 color;
out vec2 texcoord;


attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;
uniform float rainStrength;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

#include "/lib/waving.glsl"

vec3 toLinear(vec3 sRGB){
return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}
#include "/lib/end/lighting.glsl"	
	const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
									vec2(-1.,3.)/8.,
									vec2(5.0,1.)/8.,
									vec2(-3,-5.)/8.,
									vec2(-5.,5.)/8.,
									vec2(-7.,-1.)/8.,
									vec2(3,7.)/8.,
									vec2(7.,-7.)/8.);
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
    bool wavy1 = btVegetation(mc_Entity.x);
    bool mat = wavy1;
    bool emissive = false;
	color = emissive? vec4(1.0) : gl_Color;
	color.rgb = toLinear(color.rgb);
		
	gl_Position = ftransform();
	

	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	position = gbufferModelViewInverse * position;
    position.xyz += btVegetationOffset(position.xyz + cameraPosition, mc_Entity.x,
        gl_MultiTexCoord0.t < mc_midTexCoord.t, frameTimeCounter);
    gl_Position = gl_ProjectionMatrix * gbufferModelView * position;


	
	vec3 sunVec = normalize(sunPosition);
	vec3 upVec = normalize(upPosition);
	texcoord = (gl_MultiTexCoord0).xy;

	vec2 lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	
	
	
	color.rgb *= lightColor(lmcoord, normal, sunVec, -sunVec, upVec, mat && wavy1,position.y+cameraPosition.y);


}