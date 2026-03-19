// Reference: https://www.shadertoy.com/view/tllcDX

shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float R21(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 myPattern(vec2 uv) {
	vec2 uv2 = uv;
	uv2.y = uv2.y + 1.0 * (R21(uv));
	return uv2 - uv;
}

void fragment() {
	vec2 p = SCREEN_UV;
	for (int i = 0; i < 2; i++) p += myPattern(p) * 0.02;
	ALBEDO = texture(SCREEN_TEXTURE, p).rgb;
}
