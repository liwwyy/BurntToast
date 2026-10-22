

vec3 getFogColor(vec3 sVector,float cosT) {
	return pow(vec3(138,120.,180.)/255.,vec3(2.2))*0.3;
}

vec3 getSkyColor(vec3 sVector, float sunInt,float moonInt,float cosT) {

	//gradient
	vec3 grad3 = getFogColor(sVector,cosT);


	return grad3;

}


