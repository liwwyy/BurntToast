/*
!! DO NOT REMOVE !!
Base transforms and lighting: Chocapic13' shaders.
Wave displacement adapted from YoFPS (MLGImposter / NoComment1105).
Read LICENSE.md before modification or redistribution.
*/
out vec4 lmtexcoord;
out vec4 color;
out vec4 shadowPos;
out vec3 btWaterPosition;
flat out float btIsWater;
attribute vec4 mc_Entity;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
#ifdef BT_OVERWORLD
    #include "/lib/shadow_param.glsl"
    uniform vec3 sunVec;
    uniform vec4 lightCol;
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
#else
    uniform vec3 sunPosition;
    uniform vec3 upPosition;
    uniform float rainStrength;
    #ifdef BT_NETHER
        #include "/lib/nether/lighting.glsl"
    #else
        #include "/lib/end/lighting.glsl"
    #endif
#endif
void main() {
    vec4 view = gl_ModelViewMatrix * gl_Vertex;
    vec4 world = gbufferModelViewInverse * view;
    btWaterPosition = world.xyz + cameraPosition;
    btIsWater = (mc_Entity.x == 8.0 || mc_Entity.x == 9.0) ? 1.0 : 0.0;
    #ifdef WATER_WAVES
        if (btIsWater > 0.5) {
            float wave = 0.05 * sin(6.28318530718 * (frameTimeCounter * 0.75 + btWaterPosition.x / 7.0 + btWaterPosition.z / 13.0))
                       + 0.05 * sin(6.28318530718 * (frameTimeCounter * 0.6 + btWaterPosition.x / 11.0 + btWaterPosition.z / 5.0));
            float fy = fract(btWaterPosition.y + 0.001);
            world.y += clamp(wave * WATER_WAVE_STRENGTH, -fy, 1.0 - fy) * 0.5;
            view = gbufferModelView * world;
        }
    #endif
    gl_Position = gl_ProjectionMatrix * view;
    lmtexcoord.xy = gl_MultiTexCoord0.xy;
    color = gl_Color;
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    #ifdef BT_OVERWORLD
        float nDotUp = gl_Normal.y * (0.17 * 15.5 / 255.0) + 0.83 * 15.5 / 255.0;
        lmtexcoord.zw = gl_MultiTexCoord1.xy * vec2(15.5 / 255.0, nDotUp) + 0.5;
        shadowPos = vec4(1e30, 0.0, 0.0, clamp(dot(normal, sunVec) * lightCol.a, 0.0, 1.0) * gl_MultiTexCoord1.y);
        if (gl_Position.z < shadowDistance + 16.0) {
            vec4 projected = shadowProjection * shadowModelView * world;
            shadowPos.xyz = projected.xyz;
        }
    #else
        lmtexcoord.zw = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        vec3 sunDirection = normalize(sunPosition);
        vec3 upDirection = normalize(upPosition);
        shadowPos = vec4(lightColor(lmtexcoord.zw, normal, sunDirection, -sunDirection, upDirection, false, btWaterPosition.y), 0.0);
    #endif
}
