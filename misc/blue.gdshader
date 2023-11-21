shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
global uniform float blue_strength;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	color.r *= 1.0 - blue_strength;
	COLOR = color;
}
