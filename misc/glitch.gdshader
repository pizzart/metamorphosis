shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR.rgb =  vec3(0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
}

void vertex() {
	VERTEX.x = VERTEX.x + (rand(vec2(10.0, sin(TIME) * VERTEX.y)) - 0.5) * 5.0;
}