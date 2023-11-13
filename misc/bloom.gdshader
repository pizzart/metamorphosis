shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool scanlines_shown = true;
uniform bool curvature_shown = true;
uniform bool warp_shown = false;
uniform float aberration_amount = 3.0;
uniform float static_intensity = 0.0;
uniform float time_scale = 1.0;
uniform float warp_amount = 0.7;
uniform float scanlines_opacity = 0.15;
uniform float scanlines_amount = 100.0;
uniform float scanlines_speed = 0.05;
uniform float scanlines_width = 0.2;
uniform float bloom_threshold = 0.15;
uniform float bloom_strength = 1.5;
uniform float bloom_size = 4.0;
global uniform float vignette_opacity;

vec2 curve(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	return uv + delta * delta_offset;
}

vec2 warp(vec2 uv, float time) {
	float mask = smoothstep(0.0, 0.9, 0.5 - length(vec2(uv.x - uv.y) / 1.0 - tan(time / 5.0) * 5.0));
	return uv - uv * mask;
}

vec3 aberration(sampler2D screen_texture, vec2 uv, vec2 resolution) {
	float horizontal = aberration_amount / resolution.x;
	vec3 color;
	color.r = texture(screen_texture, vec2(uv.x - horizontal, uv.y)).r;
	color.b = texture(screen_texture, vec2(uv.x - horizontal, uv.y)).b;
	color.g = texture(screen_texture, uv).g;
	return color;
}

vec3 bloom(sampler2D screen_texture, vec2 uv) {
	vec3 blur = textureLod(screen_texture, uv, bloom_size).rgb;
	return max((blur - bloom_threshold) * bloom_strength, 0.0);
}

vec2 random(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(mix(dot(random(uv_index + vec2(0.0, 0.0)), uv_fract - vec2(0.0, 0.0)),
                     dot(random(uv_index + vec2(1.0, 0.0)), uv_fract - vec2(1.0, 0.0)), blur.x),
                mix(dot(random(uv_index + vec2(0.0, 1.0)), uv_fract - vec2(0.0, 1.0)),
                     dot(random(uv_index + vec2(1.0, 1.0)), uv_fract - vec2(1.0, 1.0)), blur.x), blur.y) * 0.5 + 0.5;
}

float static(sampler2D texture, vec2 uv, vec2 resolution, float time) {
	float noise = smoothstep(0.4, 0.5, noise(uv * vec2(2.0, 200.0) + vec2(10.0, time)));
	vec3 color = texture(texture, uv).rgb;
	color = clamp(color, vec3(0.0), vec3(1.0));
	return clamp(random((ceil(uv * resolution) / resolution) + fract(time)).x, 0.0, 1.0) * static_intensity;
}

float vignette(vec2 uv, vec2 resolution) {
	float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
	return clamp(pow((resolution.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
}

vec3 scanlines(vec2 uv, vec3 color, float time) {
	float scanlines = smoothstep(scanlines_width, scanlines_width + 0.5, 
	abs(sin((uv.y + time * scanlines_speed) * scanlines_amount * PI)));

	return mix(color, color * vec3(scanlines), scanlines_opacity);
}

void fragment() {
	float time = TIME / time_scale;

	vec2 uv;
	if (warp_shown) {
		uv = warp(SCREEN_UV, time);
	}
	else {
		uv = SCREEN_UV;
	}
	if (curvature_shown) {
		uv = curve(uv);
	}

	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	
	vec3 color = aberration(SCREEN_TEXTURE, uv, resolution);
	color += bloom(SCREEN_TEXTURE, uv);
	color += static(SCREEN_TEXTURE, uv, resolution, time);
	color *= vignette(uv, resolution);

	if (scanlines_shown) {
		color = scanlines(uv, color, time);
	}

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		color = vec3(0.0, 0.0, 0.0);
	}

	COLOR.rgb = color;
}