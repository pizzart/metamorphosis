shader_type canvas_item;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	COLOR.g = 1.0 * alpha;
	COLOR.r = 0.0;
	COLOR.b = 0.0;
	COLOR.a = alpha;
}