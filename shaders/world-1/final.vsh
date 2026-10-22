#version 330 compatibility

out vec4 texcoord;

// Reprojection matrices combined ONCE per vertex (fullscreen quad = a few verts) and passed
// in flat, so the fragment does 2 mat-vec mults instead of a 4-deep per-pixel matrix chain.
flat out mat4 toWorld;     // gbufferModelViewInverse * gbufferProjectionInverse
flat out mat4 toPrevClip;  // gbufferPreviousProjection * gbufferPreviousModelView

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

void main() {
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	toWorld    = gbufferModelViewInverse  * gbufferProjectionInverse;
	toPrevClip = gbufferPreviousProjection * gbufferPreviousModelView;
}
