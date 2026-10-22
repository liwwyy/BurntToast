
uniform sampler2D gaux1;

out vec4 texcoord;
flat out vec4 fogColor;
flat out vec3 flareColor;

uniform sampler2D depthtex0;
uniform float exposure;
uniform int isEyeInWater;
uniform float moonIntensity;
uniform float skyIntensity;
uniform float skyIntensityNight;
uniform float sunIntensity;

uniform float rainStrength;
uniform float aspectRatio;
uniform ivec2 eyeBrightnessSmooth;
uniform vec3 nsunColor;
uniform vec4 lightCol;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;
uniform vec3 sunColor;


vec2 tapLocation(int sampleNumber,int nb, float nbRot,float jitter)
{
    float alpha = float(sampleNumber+jitter)/nb;
    float angle = (jitter+alpha) * (nbRot * 6.28);

    float ssR = alpha;
    float sin_v, cos_v;

	sin_v = sin(angle);
	cos_v = cos(angle);

    return vec2(cos_v, sin_v)*ssR;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	fogColor.rgb = texelFetch(gaux1, ivec2(0,16),0).rgb*0.6;
	fogColor.a = 0.0;
	fogColor.rgb *= (eyeBrightnessSmooth.y/255.+0.006);

	gl_Position = ftransform();


	texcoord.xy = gl_MultiTexCoord0.xy;

	texcoord.zw = vec2(0.0);
	flareColor = vec3(0.0);
#ifdef SUN_GLARE
	vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
	// The two original perspective divides cancel; avoid infinity/infinity at the horizon.
	float projectionDivisor = abs(tpos.z) < 0.00001 ? 0.00001 : tpos.z;
	vec2 pos1 = tpos.xy / projectionDivisor;
	vec2 sunPosScreen = pos1*0.5+0.5;
	float sunVis = 0.0;
	const int nVisSamples = SUN_GLARE_SAMPLES;
	vec2 meanCenter = vec2(0.);
	for (int i = 0; i < nVisSamples; i++){
		vec2 spPos = sunPosScreen + tapLocation(i, nVisSamples, 88.0,0.0)*0.035;
		float spSunVis = texture2D(depthtex0, spPos).r < 1.0 ? 0.0 : 1.0/nVisSamples;
		sunVis += spSunVis;
		meanCenter += spSunVis * spPos;	// Readjust sun position when its partially occluded
	}
	if (sunVis > 0.0)
		meanCenter /= sunVis;
	else
		meanCenter = sunPosScreen;
	vec2 scale = vec2(1.0, aspectRatio)*0.01;
	texcoord.zw = (meanCenter - texcoord.xy)/scale;
  float truepos = sign(sunPosition.z)*1.0;		//1 -> sun / -1 -> moon
  flareColor = mix(sunColor*skyIntensity+0.00001,3*vec3(0.16, 0.24,0.36)*skyIntensityNight+0.00001,(truepos+1.0)/2.) * (1.0-rainStrength*0.95);

	flareColor = flareColor * sunVis * 2.0;


#endif
	float avgEyeIntensity = ((sunIntensity*120.+moonIntensity*4.)+skyIntensity*230.+skyIntensityNight*4.);
	// vec3(0.27)*0.18/log2(max(avgEyeIntensity*0.16+1.0,1.13))*

	if (isEyeInWater == 1){
		fogColor.rgb = (lightCol.g + skyIntensity + skyIntensityNight)*vec3(0.06,0.27,0.35)/exposure*0.015;
		fogColor.a = 0.06;
	}

}
