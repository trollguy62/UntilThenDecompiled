shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, diffuse_burley, specular_schlick_ggx;

uniform float speed : hint_range(0, 4) = 1.;
uniform float max_rot_degs : hint_range(0, 180) = 80.;

uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_noise : hint_default_black;

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

float sigmoid(float a, float x) {
	return 1. / (1. + pow(E, a * (1. - 2. * x)));
}

float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float deg2rad(float x) {
	return x * PI / 180.;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float dt = rand(world_pos.yz * world_pos.x) * 4.2069;
	float t = TIME + dt;

	vec2 nd = vec2(cos(dt), sin(dt));
	float noise = texture(texture_noise, nd * t * 0.3 * speed).r;
	noise = clamp(noise, 0., 1.);
	noise = (noise - 0.5) * 2.;

	float theta = sigmoid(10., UV.y) * noise * deg2rad(max_rot_degs);

	VERTEX *= mat3(
		vec3(cos(theta), -sin(theta), 0),
		vec3(-sin(theta), cos(theta), 0),
		vec3(0, 0, 1)
	);
}

void fragment() {
	vec2 px_size = 1.0f / vec2(textureSize(texture_albedo, 0));
	vec4 tex_albedo = texturePointSmooth(texture_albedo, UV, px_size);

	ALBEDO = tex_albedo.rgb;
	ALPHA = tex_albedo.a;
	ALPHA_SCISSOR_THRESHOLD = 0.99;
}
