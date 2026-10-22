// Original BurntToast camera-reprojection implementation. No CH Motion code.
in vec2 btUV;
uniform sampler2D colortex0;
#ifdef MOTION_BLUR
uniform sampler2D depthtex0;
uniform sampler2D colortex2;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform float frameTime;
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
flat in mat4 btClipToWorld;
flat in mat4 btWorldToPreviousClip;

vec3 btBlur(vec3 centerColor) {
    #ifdef EXCLUDE_HAND_MOTION_BLUR
        if (texture2D(colortex2, btUV).r > 0.0) return centerColor;
    #endif
    vec3 cameraDelta = cameraPosition - previousCameraPosition;
    if (frameCounter < 2 || frameTime <= 0.0 || frameTime > 0.25 || dot(cameraDelta, cameraDelta) > 4096.0)
        return centerColor;
    float depth = texture2D(depthtex0, btUV).r;
    vec4 world = btClipToWorld * vec4(btUV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    if (abs(world.w) < 0.00001) return centerColor;
    vec3 position = world.xyz / world.w;
    // The sky rotates with the camera but does not translate with it.
    if (depth < 1.0) position += cameraDelta;
    vec4 previous = btWorldToPreviousClip * vec4(position, 1.0);
    if (previous.w <= 0.00001) return centerColor;
    vec2 velocity = btUV - (previous.xy / previous.w * 0.5 + 0.5);
    // A normalized exposure interval: strength rises monotonically from 0.5 to 10.
    velocity *= (0.04 / max(frameTime, 0.0001)) * (MOTION_BLUR_STRENGTH / 5.5);
    float speed = length(velocity);
    if (speed < 0.0001) return centerColor;
    velocity *= min(1.0, 0.25 / speed);
    vec2 border = 0.5 / vec2(viewWidth, viewHeight);
    float jitter = 0.5;
    #ifdef MOTION_BLUR_NOISE
        jitter = fract(0.754877666 * gl_FragCoord.x + 0.569840296 * gl_FragCoord.y);
    #endif
    vec3 total = vec3(0.0);
    float accepted = 0.0;
    for (int sampleIndex = 0; sampleIndex < MOTION_BLUR_SAMPLES; ++sampleIndex) {
        float offset = (float(sampleIndex) + jitter) / float(MOTION_BLUR_SAMPLES) - 0.5;
        vec2 sampleUV = clamp(btUV + offset * velocity, border, 1.0 - border);
        #ifdef EXCLUDE_HAND_MOTION_BLUR
            if (texture2D(colortex2, sampleUV).r > 0.0) continue;
        #endif
        total += texture2D(colortex0, sampleUV).rgb;
        accepted += 1.0;
    }
    return accepted > 0.0 ? total / accepted : centerColor;
}
#endif
void main() {
    vec3 result = texture2D(colortex0, btUV).rgb;
    #ifdef MOTION_BLUR
        result = btBlur(result);
    #endif
    // CH-compatible advanced control. The default 1.0 leaves tone mapping intact.
    if (VANILLA_GAMMA != 1.0) {
        result = pow(max(result, vec3(0.0)), vec3(VANILLA_GAMMA));
    }
    gl_FragColor = vec4(result, 1.0);
}
