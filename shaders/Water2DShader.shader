shader_type canvas_item;

// Audio-reactive inputs (set from ForegroundWaveSegment.gd)
uniform float u_bass : hint_range(0.0, 5.0) = 0.0;
uniform float u_mids : hint_range(0.0, 5.0) = 0.0;
uniform float u_highs : hint_range(0.0, 5.0) = 0.0;

uniform float shimmer_strength : hint_range(0.0, 1.0, 0.01) = 0.15;

uniform vec4 base_color : source_color = vec4(0.1, 0.2, 0.6, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.6, 0.8, 1.2, 1.0);

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

void fragment() {
    vec2 uv = UV;

    float wave_speed = 1.0 + u_bass * 2.0;
    float wave_amp = 0.03 * (0.5 + u_bass * 1.5);
    float wave_offset = sin(uv.x * 6.2831 + TIME * wave_speed) * wave_amp;
    uv.y += wave_offset;

    float shimmer_time = TIME * (0.5 + u_highs * 3.0);
    float n = fbm(uv * 4.0 + shimmer_time);
    float shimmer = n * shimmer_strength * (0.3 + u_highs * 1.7);

    float mix_factor = clamp(u_bass * 0.3 + u_mids * 0.4 + u_highs * 0.8, 0.0, 1.0);
    vec3 col = mix(base_color.rgb, highlight_color.rgb, mix_factor) + shimmer;

    float foam_center = 0.45;
    float foam_width = 0.08;
    float foam_band = smoothstep(foam_center - foam_width, foam_center + foam_width, 1.0 - uv.y);
    foam_band *= (0.5 + u_mids * 0.5 + u_highs * 0.8);

    vec3 foam_color = vec3(1.3, 1.3, 1.6);
    col = mix(col, foam_color, foam_band);

    COLOR = vec4(col, 1.0);
}
