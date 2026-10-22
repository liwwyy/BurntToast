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


vec3 toLinear(vec3 sRGB){
return sRGB * (sRGB * (sRGB * 0.305306011 + 0.682171111) + 0.012522878);
}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 albedo = texture2D(texture,texcoord) * vec4(1.0, 1.0, 1.0, color.a);
    if (albedo.a <= 0.0) discard;
    gl_FragData[1] = vec4(1.0);
    albedo.rgb = btHandLight(color.rgb * 1.275) * toLinear(albedo.rgb) * 66.66666666666667;	//don't export to gamma 1/2.2 due to RGB11F format

/* DRAWBUFFERS:12 */
	gl_FragData[0] = albedo;

}