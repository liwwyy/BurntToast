#include "/lib/shadow_param.glsl"
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
//#define SEPARATE_AO
out vec4 lmtexcoord;
out vec4 color;
out vec4 shadowPos;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform mat4 gbufferModelView;
#include "/lib/waving.glsl"

uniform vec3 sunVec;
uniform vec4 lightCol;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define  projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)
vec4 toClipSpace3(vec3 viewSpacePosition) {
    return vec4(projMAD(gl_ProjectionMatrix, viewSpacePosition),-viewSpacePosition.z);
}


void main() {
	vec3 normal = gl_NormalMatrix * gl_Normal;
	vec3 position = mat3(gl_ModelViewMatrix) * vec3(gl_Vertex) + gl_ModelViewMatrix[3].xyz;
	vec3 world = (gbufferModelViewInverse * vec4(position, 1.0)).xyz;
    world += btVegetationOffset(world + cameraPosition, mc_Entity.x,
        gl_MultiTexCoord0.t < mc_midTexCoord.t, frameTimeCounter);
    position = (gbufferModelView * vec4(world, 1.0)).xyz;
    lmtexcoord.xy = gl_MultiTexCoord0.xy;


	float NdotU = gl_Normal.y*(0.17*15.5/255.)+(0.83*15.5/255.);
  #ifdef SEPARATE_AO
	lmtexcoord.zw = gl_MultiTexCoord1.xy*vec2(15.5/255.0,NdotU*gl_Color.a)+0.5;
  #else
  lmtexcoord.zw = gl_MultiTexCoord1.xy*vec2(15.5/255.0,NdotU)+0.5;
  #endif

	gl_Position = toClipSpace3(position);
	float diffuseSun = clamp(dot(normal,sunVec)*lightCol.a,0.0,1.0);


	shadowPos.x = 1e30;
	//skip shadow position calculations if far away
	//normal based rejection is useless in vertex shader
	if (gl_Position.z < shadowDistance + 16.0){
		position = mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz;
		shadowPos.xyz = mat3(shadowModelView) * position.xyz + shadowModelView[3].xyz;
		shadowPos.xyz = diagonal3(shadowProjection) * shadowPos.xyz + shadowProjection[3].xyz;
	}

  #ifdef SEPARATE_AO
    color.rgb = gl_Color.rgb;
  #else
    color.rgb = gl_Color.rgb*gl_Color.a;
  #endif


  if (mc_Entity.x == 10001 || btVegetation(mc_Entity.x)){
    shadowPos.w = -2.0;
    diffuseSun = diffuseSun*0.35+0.4;
    color.rgb *= 1.1;
  }

  color.a = diffuseSun*gl_MultiTexCoord1.y;


}
