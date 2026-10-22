#include "/lib/surface.glsl"
#include "/lib/end/ToD.glsl"	

uniform float nightVision;
//hardcoded lighting model, could be stored into texture
vec3 lightColor(in vec2 lmcoord, in vec3 normal, in vec3 sunVec, in vec3 moonVec, in vec3 upVec, in bool mat, in float altitude){
	float SdotU = dot(sunVec,upVec);
	float sunInt = sunIntensity(SdotU);
	float moonInt = moonIntensity(SdotU);
	
	vec3 sunlight =  sunlightColorRain(sunlightColor(SdotU),rainStrength);

	float skyL = lmcoord.t*1.03225806452-0.5/16.0*1.03225806452;
	float skyL2 = skyL*skyL;
	
	float torch_lightmap = 16.0-min(15.,(lmcoord.s-0.5/16.)*16.*16./15);
	float fallof1 = clamp(1.0 - pow(torch_lightmap/16.0,4.0),0.0,1.0);
	torch_lightmap = fallof1*fallof1/(torch_lightmap*torch_lightmap+1.0);

	float NdotL = dot(normal,sunVec);
	float NdotU = dot(normal,upVec);

	float upLight = sqrt(NdotU*0.1*0.7+0.35*0.7);
	float coef = pow(NdotU*0.4+0.6,2.)+upLight;
	coef = (mat ? abs(dot(sunVec,upVec))*0.3+NdotL*0.3+0.9 : coef);
	vec3 dayLight =  pow(vec3(138,120.,180.)/255.,vec3(2.2))*coef*0.15*clamp(altitude/100.,0.,1.) + vec3(0.015,0.0175,0.02)*0.6;
	
    #ifdef BT_HAND
        #ifdef REMOVE_HAND_TINT
            dayLight = vec3(btLuminance(dayLight));
        #endif
    #endif
    #ifdef BT_ENTITY
        #ifdef REMOVE_ENTITY_DIMENSION_TINT
            dayLight = vec3(btLuminance(dayLight));
        #endif
    #endif
    vec3 localLight = torch_lightmap * TORCH_AMOUNT * vec3(TORCH_R, TORCH_G, TORCH_B) * 11.2;
    #ifdef BT_HAND
        #ifdef REMOVE_HAND_TINT
            localLight = vec3(btLuminance(localLight));
        #endif
    #endif
    return dayLight + 0.001 + 0.01 * nightVision + localLight;

}