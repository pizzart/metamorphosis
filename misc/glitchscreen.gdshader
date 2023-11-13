shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float AMT = 0.2; //0 - 1 glitch amount
uniform float SPEED = 0.6; //0 - 1 speed

//2D (returns 0 - 1)
float random2d(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange(in vec2 seed, in float min, in float max) {
		return min + random2d(seed) * (max - min);
}

// return 1 if v inside 1d range
float insideRange(float v, float bottom, float top) {
   return step(bottom, v) - step(top, v);
}
   
void fragment() {
	float time = floor(TIME * SPEED * 60.0);
	vec3 out_col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float max_offset = AMT/2.0;
	for (float i = 0.0; i < 10.0 * AMT; i += 1.0) {
		float slice_y = random2d(vec2(time, 2345.0 + float(i)));
		float slice_h = random2d(vec2(time, 9035.0 + float(i))) * 0.25;
		float h_offset = randomRange(vec2(time, 9625.0 + float(i)), -max_offset, max_offset);
		vec2 uv_off = UV;
		uv_off.x += h_offset;
		if (insideRange(UV.y, slice_y, fract(slice_y + slice_h)) == 1.0) {
			out_col = texture(SCREEN_TEXTURE, uv_off).rgb;
		}
	}
	COLOR.rgb = out_col;
}