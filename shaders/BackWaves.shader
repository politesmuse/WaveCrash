shader_type canvas_item;

uniform float speed = 0.3;
uniform float amp = 0.03;

uniform vec4 color1 : source_color = vec4(0.05, 0.1, 0.25, 1.0);
uniform vec4 color2 : source_color = vec4(0.1, 0.2, 0.4, 1.0);

void fragment() {
    vec2 uv = UV;
    float w = sin(uv.x * 10.0 + TIME * speed) * amp;
    uv.y += w;
    float t = uv.y;
    vec4 col = mix(color1, color2, t);
    COLOR = col;
}
