shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.05, 0.05, 0.2, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.2, 0.3, 0.6, 1.0);

void fragment() {
    float t = UV.y;
    vec4 col = mix(top_color, bottom_color, t);
    COLOR = col;
}
