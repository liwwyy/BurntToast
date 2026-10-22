out vec2 btUV;
#ifdef MOTION_BLUR
flat out mat4 btClipToWorld;
flat out mat4 btWorldToPreviousClip;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
#endif
void main() {
    gl_Position = ftransform();
    btUV = gl_MultiTexCoord0.xy;
    #ifdef MOTION_BLUR
        btClipToWorld = gbufferModelViewInverse * gbufferProjectionInverse;
        btWorldToPreviousClip = gbufferPreviousProjection * gbufferPreviousModelView;
    #endif
}
