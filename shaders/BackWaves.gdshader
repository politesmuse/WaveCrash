shader_type canvas_item;

uniform float speed = 0.5;
uniform float amp = 0.08;

uniform vec4 color1 : source_color = vec4(0.05, 0.1, 0.25, 1.0);
uniform vec4 color2 : source_color = vec4(0.1, 0.2, 0.4, 1.0);

void fragment() {
    // Use screen UV so the effect is independent of the sprite's texture size
    vec2 uv = SCREEN_UV;

    // Time-based horizontal sine waves
    float phase = uv.x * 10.0 + TIME * speed;
    float w = sin(phase) * amp;

    uv.y += w;

    float t = clamp(uv.y, 0.0, 1.0);
    vec4 col = mix(color1, color2, t);
    COLOR = col;
}
