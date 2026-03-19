shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D texture_albedo : source_color, filter_linear;
uniform sampler2D texture_influence : hint_default_black, filter_linear;
uniform sampler2D texture_noise : hint_default_black, filter_linear;

uniform float min_influence = 0.0;
uniform float max_influence = 1.0;
uniform float speed = 1.0;

void vertex() {
	float v = texture(texture_influence, UV).r * texture(texture_noise, (UV / 3.0) + vec2(TIME * speed)).r;
	VERTEX.z += mix(min_influence, max_influence, v);
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

void fragment() {
	vec2 px_size = 1.0f / vec2(textureSize(texture_albedo, 0));
	vec4 albedo_tex = texturePointSmooth(texture_albedo, UV, px_size);

	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 1.0;
}
