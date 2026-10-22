
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

out vec4 lmtexcoord;
out vec4 color;
out vec4 normalMat;
#ifdef MC_NORMAL_MAP
out vec4 tangent;
attribute vec4 at_tangent; 
#endif


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	lmtexcoord.xy = (gl_MultiTexCoord0).xy;

	vec2 lmcoord = gl_MultiTexCoord1.xy/255.;
	lmtexcoord.zw = lmcoord*lmcoord;

	gl_Position = ftransform();
	color = gl_Color;
	
	
	#ifdef MC_NORMAL_MAP
		tangent = vec4(normalize(gl_NormalMatrix *at_tangent.rgb),at_tangent.w);
	#endif

	normalMat = vec4((gl_NormalMatrix *gl_Normal),1.0);	

}