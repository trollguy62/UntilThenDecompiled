shader_type spatial;

uniform sampler2D tex_albedo : hint_default_white;
uniform vec4 albedo : source_color = vec4(1);
uniform float roughness : hint_range(0, 1) = 0.0;
uniform float metallic : hint_range(0, 1) = 1.0;

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

void fragment() {
	vec4 tex = texturePointSmooth(tex_albedo, UV);
	ALBEDO = tex.rgb * albedo.rgb;
	ALPHA = tex.a * albedo.a;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
