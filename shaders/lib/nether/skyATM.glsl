#define DRAW_SUN //if not using custom sky



vec3 getFogColor(vec3 sVector,float cosT) {
	return vec3(1.4,0.22,0.0)*1.;
}

vec3 getSkyColor(vec3 sVector, float sunInt,float moonInt,float cosT) {

	//gradient
	vec3 grad3 = getFogColor(sVector,cosT);

	return grad3;

}




