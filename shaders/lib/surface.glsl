#ifndef BURNTTOAST_SURFACE
#define BURNTTOAST_SURFACE
float btLuminance(vec3 value) {
    return dot(value, vec3(0.2126, 0.7152, 0.0722));
}
// Illumination is in normalized, exposed, linear scene units here.
vec3 btSurfaceLight(vec3 illumination) {
    illumination = max(illumination, vec3(0.0));
    #ifdef MINIMUM_VISIBILITY
        illumination = max(illumination, vec3(MIN_VISIBILITY_STRENGTH));
    #endif
    return illumination;
}
vec3 btHandLight(vec3 illumination) {
    #ifdef REMOVE_HAND_TINT
        illumination = vec3(btLuminance(illumination));
    #endif
    return btSurfaceLight(illumination);
}
#endif
