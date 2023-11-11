shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
//	COLOR.rg = SCREEN_UV.xy;
//	VERTEX = VERTEX * sin(TIME);
}

void vertex() {
	VERTEX = VERTEX + rand(vec2(0.0, sin(TIME) * sin(VERTEX.y))) * vec2(5.0, 0.0);
}