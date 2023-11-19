shader_type canvas_item;

// Allows you to control the output color in the Shader Params in the Inspector.
uniform vec4 silhouette_color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// We sample the screen texture at this point, which has the Mask node's pixels
	// rendered on it.
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color;

	// If the pixel's value is lower than the Mask's output color, it means the
	// mask is being occluded, so we draw the silhouette instead.
	if (screen_color.rgb != vec3(0.0, 1.0, 0.0)) {
		COLOR.rgb = silhouette_color.rgb;
	}
}