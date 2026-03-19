shader_type spatial;
render_mode cull_disabled;

uniform float width = 1.0;

uniform sampler2D frame_1;
uniform sampler2D frame_2;
uniform sampler2D frame_3;

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
	vec2 uv = UV * vec2(width, 1);
	int i = int(floor(uv.x) + TIME * 8.0) % 3;
	
	vec2 px_size = 1.0f / vec2(textureSize(frame_1, 0));
	vec4 tex_1 = texturePointSmooth(frame_1, uv, px_size);
	vec4 tex_2 = texturePointSmooth(frame_2, uv, px_size);
	vec4 tex_3 = texturePointSmooth(frame_3, uv, px_size);
	vec4 tex = mix(tex_1, mix(tex_2, tex_3, float(i - 1)), float(min(i, 1)));
	
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	EMISSION = tex.rgb * 1.5;
}
