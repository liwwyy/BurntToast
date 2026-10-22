
#ifdef fsh
	#ifdef Global
		#define MOTION_BLUR
		#define MOTION_BLUR_NOISE
		#define MOTION_BLUR_STRENGTH 5.5 //[0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10]

		uniform sampler2D colortex0;
		in vec4 texcoord;

		#ifdef MOTION_BLUR
			uniform vec3 cameraPosition;
			uniform vec3 previousCameraPosition;

			uniform float frameTime;
			uniform sampler2D depthtex0;

			// Combined reprojection matrices, computed once per vertex in final.vsh.
			flat in mat4 toWorld;     // gbufferModelViewInverse * gbufferProjectionInverse
			flat in mat4 toPrevClip;  // gbufferPreviousProjection * gbufferPreviousModelView

			float rand(vec2 coord) {
				return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
			}

			//////////////////////////////////////////////////////////////////////////////////////////////////
			// Important Motion Blur Setting Thingies
			#define MOTION_BLUR_SAMPLES 8 //[4 6 8 10 12 16 20 24]
			const float maxVel = 3.0;

			vec3 MotionBlur(in vec3 color) {
				float depth = texture(depthtex0, texcoord.st).x; // single depth read, reused below
				if(depth < 0.56) { //hand
					return color;
				}

				// Current fragment in NDC space
				vec4 curNDC = vec4(texcoord.st * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);

				// NDC -> world. The perspective divide commutes through the rigid modelview
				// inverse, so the two inverse matrices fold into one (toWorld).
				vec4 worldH = toWorld * curNDC;
				vec3 worldPos = worldH.xyz / worldH.w + (cameraPosition - previousCameraPosition);

				// World -> previous-frame clip -> previous NDC
				vec4 prevClip = toPrevClip * vec4(worldPos, 1.0);
				vec2 prevNDC = prevClip.xy / prevClip.w;

				// max() guards against a divide-by-zero on the first frame / while paused (frameTime == 0)
				vec2 vel = clamp((curNDC.xy - prevNDC) * (1.0 / max(frameTime, 0.0001)) * 0.003, vec2(-maxVel), vec2(maxVel));

				// Camera is essentially still: skip the sample loop entirely (free perf win when standing still)
				if (dot(vel, vel) < 1.0e-7) {
					return color;
				}

				#ifdef MOTION_BLUR_NOISE
					float noise = rand(texcoord.st);
				#else
					float noise = 0.0;
				#endif

				vec3 col = vec3(0.0);
				int fSamples = (MOTION_BLUR_SAMPLES - 1) / 2;

				// Higher MOTION_BLUR_STRENGTH = more blur. The per-sample offset is inversely
				// proportional to this divisor, so mirror the 0.5..10 slider range (0.5 + 10 = 10.5)
				// to flip the direction: strength 10 -> divisor 0.5 (max blur), strength 0.5 -> 10 (min).
				float blurDivisor = 10.5 - MOTION_BLUR_STRENGTH;

				for (int i = -fSamples; i <= fSamples; ++i) {
					vec2 coord = texcoord.st + vel * (float(i) + noise) / blurDivisor;
					col += texture(colortex0, coord).xyz;
				}

				// Divide by the real sample count so the image keeps its brightness while moving
				return col / float(2 * fSamples + 1);
			}
		#endif
		//////////////////////////////////////////////////////////////////////////////////////////////////

		// This pack runs the blur in the `final` program, which writes straight to the
		// screen (no render targets), removing one full-screen colortex write per frame.

		void main() {
			vec3 color = texture(colortex0, texcoord.st).xyz;

			#ifdef MOTION_BLUR
				color = MotionBlur(color);
			#endif

			// Iris bypasses vanilla's final tonemap/gamma stage whenever a shaderpack is active,
			// which leaves the frame brighter / lower-contrast than shaders-off. Re-apply an
			// approximate gamma to restore a vanilla-like look. 1.0 = off; higher = darker + more
			// contrast. Tune to taste against shaders-off.
			#define VANILLA_GAMMA 1.0 //[1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.5]
			color = pow(max(color, 0.0), vec3(VANILLA_GAMMA));

			gl_FragData[0] = vec4(color, 1.0);
		}
	#endif
#endif
