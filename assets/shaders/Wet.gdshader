shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

global uniform float rain_level;
global uniform sampler2D wet_tex_distort : hint_normal, filter_linear;
global uniform sampler2D wet_tex_ripple : hint_normal, filter_nearest;

uniform bool albedo_mult = false;
uniform vec4 albedo : source_color;
uniform sampler2D tex_albedo : source_color, hint_default_black, filter_linear;
uniform sampler2D tex_roughness : hint_default_white, filter_linear;
uniform float global_wet_roughness = 1.0;
uniform sampler2D tex_wetmap : hint_default_black, filter_linear;
uniform sampler2D tex_metallic : hint_default_black, filter_linear;
uniform bool normal_smooth_sampling = false;
uniform sampler2D tex_normal : hint_normal, filter_linear;
uniform float distort = 0.0;
uniform float max_normal_depth = 1.0;

vec4 texturePointSmooth(sampler2D smp, vec2 uv) {
	vec2 pixel_size = 1.0f / vec2(textureSize(smp, 0));

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

vec2 uv_ripple(vec2 uv1) {
	vec2 p = floor(uv1);
	p = fract(p * vec2(233.34, 851.74));
	p += dot(p, p + 23.45);

	float o = fract(p.x * p.y) + TIME;
	o = floor(mod(o * 16.0, 16.0));

	vec2 uvr = vec2(
		mod(o, 4.0),
		floor(o / 4.0)
	) / 4.0;

	uvr += fract(uv1) / vec2(4.0);
	return uvr;
}

vec3 normal_ripple(vec2 uv) {
	vec2 uv1 = uv * (vec2(textureSize(tex_albedo, 0)) / vec2(textureSize(wet_tex_ripple, 0)));
	vec2 uvr = uv_ripple(uv1 * 6.0);
	vec2 uvd = uv1 + vec2(TIME * 0.04);
	vec3 n_ripple = texture(wet_tex_ripple, uvr).rgb;
	vec3 n_distort = texture(wet_tex_distort, uvd).rgb * distort;
	return (n_ripple + n_distort) / (distort + 1.0);
}

void fragment() {
	vec4 alb = texturePointSmooth(tex_albedo, UV) * mix(vec4(1), vec4(albedo.rgb, 1), float(albedo_mult));
	vec2 wet = texturePointSmooth(tex_wetmap, UV).rg * rain_level;
	float wet_depth = clamp(wet.g, 0, 1);

	ALBEDO = alb.rgb * mix(ROUGHNESS, 1.0, 0.6);
	ALPHA = alb.a;
	ALPHA_SCISSOR_THRESHOLD = 0.01;

	float roughness = texturePointSmooth(tex_roughness, UV).r;
	roughness = mix(roughness, global_wet_roughness, rain_level);

	ROUGHNESS = roughness * (1.0 - wet.r);
	METALLIC = texturePointSmooth(tex_metallic, UV).g;
	SPECULAR = mix(0.5, 0.84, rain_level);

	vec3 normal_tex = mix(
		texture(tex_normal, UV).rgb,
		texturePointSmooth(tex_normal, UV).rgb,
		float(normal_smooth_sampling)
	);

	NORMAL_MAP = mix(normal_tex, normal_ripple(UV), wet_depth);
	NORMAL_MAP_DEPTH = mix(max_normal_depth, 0.05, wet_depth);
}
