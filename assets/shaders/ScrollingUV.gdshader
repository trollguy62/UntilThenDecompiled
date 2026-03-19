shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, diffuse_burley;

uniform sampler2D tex_albedo : source_color;
uniform vec4 albedo : source_color = vec4(1, 1, 1, 1);
uniform vec2 uv_mult = vec2(1, 1);
uniform vec2 uv_offset = vec2(0, 0);
uniform vec2 speed = vec2(1, 1);
uniform float alpha_scissor : hint_range(0.01, 1) = 0.01;
// TODO: Used in Ch5Sc8 TEMPORARY
uniform vec4 temp_emission : source_color = vec4(0);

vec4 texturePointSmooth(sampler2D smp, vec2 uv) {
	vec2 pixel_size = 1. / vec2(textureSize(smp, 0));
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
	vec2 uv = UV * uv_mult + uv_offset + TIME * speed;
	vec4 c = texturePointSmooth(tex_albedo, uv);
	ALBEDO = c.rgb * albedo.rgb;
	ALPHA = c.a * albedo.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;

	float k = (c.r + c.g + c.b) / 3.;
	EMISSION = vec3(pow(k, 32.)) * temp_emission.rgb * temp_emission.a;
}
