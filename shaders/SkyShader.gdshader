shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.05, 0.05, 0.2, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.2, 0.3, 0.6, 1.0);

// Subtle horizontal scroll using SCREEN_UV so it doesn't depend on texture UV
uniform float sky_scroll_speed = 0.01;

void fragment() {
    // Use screen UV so any texture/scale works
    vec2 suv = SCREEN_UV;
    suv.x += TIME * sky_scroll_speed;

    // Loop the sky gradient smoothly
    float t = fract(suv.y);
    vec4 col = mix(top_color, bottom_color, t);

    COLOR = col;
}
