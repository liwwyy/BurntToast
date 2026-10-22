// The hand mask must clear every frame, including when no hands are visible.
// Iris reads these directives from block comments. GLSL must not compile the
// symbolic format names: RGB8, R8, and R11F_G11F_B10F are not GLSL constants.
/*
const int colortex0Format = RGB8;
const int colortex1Format = R11F_G11F_B10F;
const int colortex2Format = R8;
const int colortex4Format = R11F_G11F_B10F;
*/
const bool colortex2Clear = true;
// Iris directive parsing requires four literals, even though GLSL allows vec4(0.0).
const vec4 colortex2ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
