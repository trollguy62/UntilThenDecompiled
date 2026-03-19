shader_type spatial;
render_mode depth_prepass_alpha, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color;
uniform float speed = 5.0;
uniform float x_extent = 0.05;
uniform float y_extent = 0.05;
uniform float time_offset : hint_range(0, 1) = 0.0;

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

void vertex() {
	float t = TIME + (time_offset * 6.283);
	float time_adj = ((sin(cos(speed * t)) + 1.0) * 0.58);
	float dx = UV.x * UV.x * x_extent * time_adj;
	float dy = UV.y * UV.y * y_extent * time_adj;
	VERTEX = VERTEX + vec3(dx, dy, 0.0);
}

void fragment() {
	vec4 tex = texturePointSmooth(texture_albedo, UV);
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 1.0f;
}
