#ifndef BURNTTOAST_WAVING
#define BURNTTOAST_WAVING
// Adapted from Sildur's Enhanced Default v1.20 Fancy by Sildur.
// Original notice: licenses/Sildur-Enhanced-Default-Notice.txt.
vec3 btFoliageWave(in vec3 pos, in float phase, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
	float magnitude = sin(phase*fm + dot(pos, vec3(0.5))) * mm + ma;
	vec3 d012 = sin(vec3(f0, f1, f2)*phase);
	
    vec3 ret;
		 ret.x = phase*f3 + d012.x + d012.y - pos.x + pos.z + pos.y;
		 ret.z = phase*f4 + d012.y + d012.z + pos.x - pos.z + pos.y;
		 ret.y = phase*f5 + d012.z + d012.x + pos.z + pos.y - pos.y;
		 ret = sin(ret)*magnitude;
	
    return ret;
}

vec3 btFoliageMove(in vec3 pos, in float phase, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = btFoliageWave(pos, phase, 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = btFoliageWave(pos+move1, phase, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}
vec3 btVegetationOffset(vec3 world, float id, bool top, float seconds) {
    float phase = 150.79 * seconds * WAVING_SPEED;
    vec3 offset = vec3(0.0);
    #ifdef WAVING_LEAVES
        if (id == 10018.0)
            offset = btFoliageMove(world, phase, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041,
                vec3(1.0, 0.2, 1.0), vec3(0.5, 0.1, 0.5));
    #endif
    #ifdef WAVING_VINES
        if (id == 10106.0)
            offset = btFoliageMove(world, phase, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041,
                vec3(0.5, 1.0, 0.5), vec3(0.25, 0.5, 0.25));
    #endif
    #ifdef WAVING_PLANTS
        if ((id == 10059.0 && top) || (id == 10175.0 && top) || id == 10176.0)
            offset = btFoliageMove(world, phase, 0.0041, 0.0070, 0.0044, 0.0038, 0.0240, 0.0,
                vec3(0.8, 0.0, 0.8), vec3(0.4, 0.0, 0.4));
        if (id == 10031.0 && top)
            offset = btFoliageMove(world, phase, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0,
                vec3(3.0, 1.6, 3.0), vec3(0.0));
    #endif
    #ifdef WAVING_FIRE
        if (id == 10051.0 && top)
            offset = btFoliageMove(world, phase, 0.0105, 0.0096, 0.0087, 0.0063, 0.0097, 0.0156,
                vec3(1.2, 0.4, 1.2), vec3(0.8));
    #endif
    return offset * WAVING_STRENGTH;
}
bool btVegetation(float id) {
    return id == 10018.0 || id == 10106.0 || id == 10059.0 || id == 10031.0
        || id == 10175.0 || id == 10176.0 || id == 10051.0;
}
#endif
