shader_type spatial;

uniform sampler2D tex_albedo : source_color;
uniform sampler2D tex_wind;
uniform bool use_tex_wind = false;

uniform vec4 transmission : source_color = vec4(0, 0, 0, 1);
uniform float roughness : hint_range(0, 1) = 1.;
uniform float vertical_stiffness = 2.;

uniform float max_wind_rot = 10.;
uniform float wind_speed = 1.;
uniform float horizontal_speed = 1.;
uniform float horizontal_curl = 1.;
uniform float time_offset = 0.;

const float TWO_PI = 6.28318530718;

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

void vertex() {
	float t = TIME + time_offset;
	t = sin(wind_speed * t)
		* radians(sin(UV.x * horizontal_curl * TWO_PI + t * horizontal_speed)
		* max_wind_rot);
	float ys = use_tex_wind ? texture(tex_wind, UV).r : pow(UV.y, vertical_stiffness);

	VERTEX.x += sin(t) * ys;
	VERTEX.y -= (cos(t) - 1.) * ys;
}

void fragment() {
	vec4 c = texturePointSmooth(tex_albedo, UV);
	ALBEDO = c.rgb;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.98;

	BACKLIGHT = transmission.rgb * transmission.a;
	ROUGHNESS = roughness;
}
