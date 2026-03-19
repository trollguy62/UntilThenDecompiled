shader_type spatial;
render_mode depth_prepass_alpha, diffuse_burley, specular_schlick_ggx, cull_disabled, unshaded;

uniform vec3 scale = vec3(1, 1, 1);
uniform vec3 offset = vec3(0, 0, 0);
uniform bool flip_h = false;
uniform bool flip_v = false;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform float normal_depth : hint_range(0, 16) = 1.0f;
uniform vec4 emission_mult : source_color = vec4(1.0f);
uniform float emission_strength : hint_range(0, 16) = 0.0f;

uniform sampler2D texture_albedo : source_color, filter_linear;
uniform sampler2D texture_normal : hint_normal, filter_linear;
uniform sampler2D texture_emission : hint_default_black, filter_linear;

uniform vec4 region_albedo = vec4(0, 0, 1, 1);
uniform vec4 region_normal = vec4(0, 0, 1, 1);
uniform vec4 region_emission = vec4(0, 0, 1, 1);

uniform vec4 margin_albedo = vec4(0);
uniform vec4 margin_normal = vec4(0);
uniform vec4 margin_emission = vec4(0);

uniform float glitch_fac : hint_range(0, 1) = 0.0;

uniform bool debug_show_frame = false;

void vertex() {
	VERTEX = VERTEX * scale + offset;
	UV = vec2(
		flip_h ? 1. - UV.x : UV.x,
		flip_v ? 1. - UV.y : UV.y
	);
}

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

vec4 sample(sampler2D tex, vec2 uv, vec4 region, vec4 margin) {
	vec2 px_size = 1.0f / vec2(textureSize(tex, 0));
	vec2 uvs = px_size * (uv * (region.zw + margin.zw) + (region.xy - margin.xy));
	return texturePointSmooth(tex, uvs, px_size);
}

float R21(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 alphaComposite(vec4 Ca, vec4 Cb) {
	float a0 = Ca.a + (Cb.a * (1. - Ca.a));
	return (Ca * Ca.a + Cb * Cb.a * (1. - Ca.a)) / a0;
}

float alphaMask(vec2 uv, vec4 region, vec4 margin) {
	float w = region.z + margin.z;
	float h = region.w + margin.w;
	return step(margin.x / w, uv.x)
		 * step(margin.y / h, uv.y)
		 * step(uv.x, (region.z + margin.x) / w)
		 * step(uv.y, (region.w + margin.y) / h);
}

void fragment() {
	vec2 uvc = UV - vec2(0.5);

	float debug_frame_mask = debug_show_frame ? clamp(step(0.49, abs(uvc.x)) + step(0.49, abs(uvc.y)), 0, 1) : 0.;
	float mask = max(alphaMask(UV, region_albedo, margin_albedo), debug_frame_mask);

	vec4 albedo_tex = mix(
		sample(texture_albedo, UV, region_albedo, margin_albedo),
		vec4(1, 0, 0, 1),
		debug_frame_mask
	);

	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = mix(0, albedo.a * albedo_tex.a, mask);
	ALPHA_SCISSOR_THRESHOLD = 1.0f;

	vec2 texs = vec2(textureSize(texture_albedo, 0));
	vec2 uvg = floor(UV * texs) / texs;
	float static = R21(uvg + vec2(TIME * 0.01));
	ALBEDO = alphaComposite(vec4(vec3(static), glitch_fac), vec4(ALBEDO, ALPHA)).rgb;

	NORMAL_MAP = sample(texture_normal, UV, region_normal, margin_normal).rgb;
	NORMAL_MAP_DEPTH = normal_depth;

	vec4 emission_tex = sample(texture_emission, UV, region_emission, margin_emission);
	EMISSION = emission_tex.rgb * emission_tex.a * emission_mult.rgb * emission_mult.a * emission_strength;
}
