#include "/lib/surface.glsl"

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

in vec4 color;

in vec2 texcoord;




uniform sampler2D texture;
uniform vec4 entityColor;


vec3 toLinear(vec3 sRGB){
return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 albedo = texture2D(texture,texcoord);
	albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    albedo.rgb = btSurfaceLight(color.rgb * 1.275) * toLinear(albedo.rgb) * 66.66666666666667;	//don't export to gamma 1/2.2 due to RGB11F format
	albedo.a *= color.a;
/* DRAWBUFFERS:1 */
	gl_FragData[0] = albedo;
}