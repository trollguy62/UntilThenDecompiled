shader_type spatial;

uniform sampler2D display : source_color, filter_linear;
uniform sampler2D display_off : source_color, filter_linear;
uniform float power : hint_range(0, 1) = 1.;
uniform float static_blend : hint_range(0, 1) = 0.;


vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size) {
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);

	vec2 uv_pixels = uv / pixel_size;
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;

	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	uv = uv_pixels_floor * pixel_size;
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 sigmoid(vec2 x, vec2 p) {
	return 1. / (vec2(1.) + pow(vec2(E), -p * x));
}

float static(vec2 px_size, vec2 uv, float t, float interval, float p, float seed) {
	vec2 half_px_size = px_size / 2.0;

	t = sqrt(interval * floor(t / interval));
	uv += px_size * 69. * seed;

	vec2 uv_q1 = px_size * floor((uv - half_px_size * vec2(1, -1)) / px_size);
	vec2 uv_q2 = px_size * floor((uv - half_px_size * vec2(-1, -1)) / px_size);
	vec2 uv_q3 = px_size * floor((uv - half_px_size * vec2(-1, 1)) / px_size);
	vec2 uv_q4 = px_size * floor((uv - half_px_size * vec2(1, 1)) / px_size);

	vec2 sig_x = fract((uv - half_px_size) / px_size) - vec2(0.5);
	vec2 blend = sigmoid(sig_x, vec2(p));

	float c = mix(
		mix(rand(uv_q4 * t), rand(uv_q1 * t), blend.y),
		mix(rand(uv_q3 * t), rand(uv_q2 * t), blend.y),
		blend.x
	);

	return clamp(pow(c, 2.0), 0.1, 0.5);
}

float sin_bounded(float x, float a, float b) {
	float n = (b - a) / 2.;
	return n * sin(x) + n + a;
}

void fragment() {
	vec4 tex = texturePointSmooth(display, UV, 1.0f / vec2(textureSize(display, 0)));

	float c = 1. - pow(abs(0.5 - UV.y), 2. * power);
	c *= sin_bounded(TIME * 10. + UV.y * 1000., 0.9, 1.0);

	float static_aa = 100. / pow(length(VIEW), 2.);
	vec3 world_pos = (MODEL_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float static_seed = rand(world_pos.xy + vec2(world_pos.z));
	float static = static(1. / vec2(160., 90.), UV, TIME, 1./23., static_aa, static_seed);

	vec2 px_size = 1.0f / vec2(textureSize(display_off, 0));
	ALBEDO = mix(
		texturePointSmooth(display_off, UV, px_size).rgb * 0.5,
		tex.rgb * 2.,
		power
	) + vec3(0.16 * power);

	EMISSION = mix(
		pow(tex.rgb * c, vec3(4.)) * 3.5,
		vec3(static * pow(c, 2.)),
		static_blend
	);

	ROUGHNESS = 0.1;
	METALLIC = 0.2;
}
