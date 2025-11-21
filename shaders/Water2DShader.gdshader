shader_type canvas_item;

// Audio-Reactive Inputs
uniform float u_bass  : hint_range(0.0, 5.0) = 0.0;
uniform float u_mids  : hint_range(0.0, 5.0) = 0.0;
uniform float u_highs : hint_range(0.0, 5.0) = 0.0;

// Color Controls
uniform vec4 base_color      : source_color = vec4(0.1, 0.2, 0.6, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.6, 0.8, 1.2, 1.0);

// Shimmer Controls
uniform float shimmer_strength : hint_range(0.0, 1.0, 0.01) = 0.15;

// Texture & Tiling
uniform sampler2D water_tex : source_color, repeat_enable, filter_linear;
uniform vec2 tex_scale = vec2(3.0, 3.0);
uniform vec2 tex_scroll_speed = vec2(0.05, 0.0);

// Glow
uniform float glow_base = 0.8;
uniform float glow_music_boost = 2.0;

// Normal & Spec Controls
uniform float normal_distort_base  : hint_range(0.0, 2.0, 0.01) = 0.4;
uniform float mids_normal_boost    : hint_range(0.0, 3.0, 0.01) = 1.0;
uniform float highs_normal_boost   : hint_range(0.0, 3.0, 0.01) = 1.5;
uniform float specular_strength    : hint_range(0.0, 2.0, 0.01) = 0.7;
uniform float specular_sharpness   : hint_range(1.0, 64.0, 1.0) = 16.0;

// Simple Hash/Noise for Micro Waves
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise2d(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// Height field used for both shading & pseudo-normals
float height_field(vec2 uv, float audio_scale) {
    // Base broad wave motion (keep subtle; geometry already carries main shape)
    float wave = sin(uv.x * 10.0 + TIME * (0.5 + u_bass * 1.5)) * 0.03;

    // Micro-wave detail from noise, scaled by audio
    float t = TIME * (0.5 + u_highs * 2.0);
    float micro = fbm(uv * 6.0 + vec2(0.0, t)) * 0.04 * audio_scale;

    return wave + micro;
}

void fragment() {
    // Use screen UV so it matches the WaterMesh on screen
    vec2 suv = SCREEN_UV;

    // Audio factor that will drive normal distortion
    float audio_scale =
        normal_distort_base
        + u_mids  * mids_normal_boost
        + u_highs * highs_normal_boost;

	// Water Texture
	vec2 tex_uv = vec2(suv.x, 1.0 - suv.y) * tex_scale + tex_scroll_speed * TIME;
	vec3 tex_col = texture(water_tex, tex_uv).rgb;

    // Base gradient color for depth
    float depth_t = clamp(suv.y, 0.0, 1.0);
    vec3 grad_col = mix(base_color.rgb, highlight_color.rgb, depth_t);

	// Shimmer from Highs
    float shimmer = fbm(suv * 8.0 + vec2(TIME * 0.5, 0.0));
    shimmer *= shimmer_strength * (0.3 + u_highs * 1.7);
    grad_col += shimmer * 0.4;

	// Combined Effects
	vec3 col = grad_col * tex_col + shimmer;

    // ─── Fake normal from height field ───────────────────────
    // Sample a small neighborhood of the height field
    float eps = 0.002;
    float hC = height_field(suv, audio_scale);
    float hR = height_field(suv + vec2(eps, 0.0), audio_scale);
    float hL = height_field(suv - vec2(eps, 0.0), audio_scale);
    float hU = height_field(suv + vec2(0.0, eps), audio_scale);
    float hD = height_field(suv - vec2(0.0, eps), audio_scale);

    // Approximate derivatives
    float dx = hR - hL;
    float dy = hU - hD;

    // Build a pseudo-normal (z points "out of screen")
    vec3 normal = normalize(vec3(-dx, -dy, 0.5));

    // Fake light direction (from top-right-ish)
    vec3 light_dir = normalize(vec3(0.4, -0.7, 0.6));

    // Diffuse term
    float ndotl = max(dot(normal, light_dir), 0.0);

    // Specular term, sharper when highs are strong
    vec3 view_dir = vec3(0.0, 0.0, 1.0);
    vec3 half_vec = normalize(light_dir + view_dir);
    float ndoth = max(dot(normal, half_vec), 0.0);
    float shininess = specular_sharpness * (1.0 + u_highs * 1.5);
    float spec = pow(ndoth, shininess) * specular_strength * (0.3 + u_highs);

    // Apply lighting
    col *= 0.4 + 0.6 * ndotl; // base diffuse
    col += vec3(spec);

	// Audio Glow
	float music_energy = max(max(u_bass, u_mids), u_highs);
	float glow_factor = glow_base + music_energy * glow_music_boost;
	col *= glow_factor;

    COLOR = vec4(col, 1.0);
}
