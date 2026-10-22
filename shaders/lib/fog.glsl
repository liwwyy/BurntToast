#ifndef BURNTTOAST_FOG
#define BURNTTOAST_FOG
uniform float far;
uniform float blindness;
uniform float darknessFactor;
uniform sampler2D colortex2;
// rainStrength and isEyeInWater are declared by the composite program.
float btEdgeFog(float distanceFromCamera) {
    float endDistance = max(FOG_END * far, 1.0);
    float startDistance = min(FOG_START * far, endDistance - 0.01);
    return smoothstep(startDistance, endDistance, distanceFromCamera);
}
vec3 btFog(vec3 scene, vec3 atmosphere, float distanceFromCamera,
           vec2 uv, float nightAmount) {
    #ifdef FOG_ENABLED
        // Hands use the same environment illumination but not distant world fog.
        if (texture2D(colortex2, uv).r > 0.0) return scene;
        float amount = 0.0;
        #ifdef BT_OVERWORLD
            #ifdef FOG_DAY
                amount += (1.0 - nightAmount) * FOG_DAY_STRENGTH;
            #endif
            #ifdef FOG_NIGHT
                amount += nightAmount * FOG_NIGHT_STRENGTH;
            #endif
            #ifdef FOG_RAIN
                amount = mix(amount, FOG_RAIN_STRENGTH, rainStrength);
            #endif
        #endif
        #ifdef BT_NETHER
            #ifdef FOG_NETHER
                amount = FOG_NETHER_STRENGTH;
            #endif
        #endif
        #ifdef BT_END
            #ifdef FOG_END_DIMENSION
                amount = FOG_END_STRENGTH;
            #endif
        #endif
        // A medium replaces atmosphere rather than stacking opaque fog layers.
        if (isEyeInWater == 1) {
            amount = 0.0;
            #ifdef FOG_WATER
                amount = FOG_WATER_STRENGTH;
                atmosphere = vec3(0.025, 0.10, 0.13);
            #endif
        } else if (isEyeInWater == 2) {
            amount = 0.0;
            #ifdef FOG_LAVA
                amount = FOG_LAVA_STRENGTH;
                atmosphere = vec3(0.40, 0.075, 0.005);
            #endif
        } else if (isEyeInWater == 3) {
            amount = 0.0;
            #ifdef FOG_POWDER_SNOW
                amount = FOG_POWDER_SNOW_STRENGTH;
                atmosphere = vec3(0.45, 0.55, 0.65);
            #endif
        }
        #ifdef FOG_BLINDNESS
            float blindAmount = clamp(blindness * FOG_BLINDNESS_STRENGTH, 0.0, 1.0);
            atmosphere = mix(atmosphere, vec3(0.0), blindAmount);
            amount = max(amount, blindAmount);
        #endif
        #ifdef FOG_DARKNESS
            float darkAmount = clamp(darknessFactor * FOG_DARKNESS_STRENGTH, 0.0, 1.0);
            atmosphere = mix(atmosphere, vec3(0.0), darkAmount);
            amount = max(amount, darkAmount);
        #endif
        float fogWeight = clamp(btEdgeFog(distanceFromCamera) * FOG_STRENGTH * amount, 0.0, 1.0);
        return mix(scene, atmosphere, fogWeight);
    #else
        return scene;
    #endif
}
#endif
