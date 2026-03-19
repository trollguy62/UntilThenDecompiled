shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

float discretize(float steps, float value) {
	return floor(steps * value) / steps;
}

float eye(vec2 uv, float from, float to) {
	return smoothstep(from, to, length(vec2(abs(uv.x) - 0.15, uv.y) * vec2(1., 9./16.)));
}

void fragment() {
	vec2 uv = UV - vec2(0.5);

	float eye_frame = eye(uv, 0.21, 0.24);
	float eye_distort = eye(uv, 0.18, 0.245);
	vec2 distort = normalize(uv) * 0.05 * eye_distort;

	COLOR.r = texture(SCREEN_TEXTURE, SCREEN_UV + distort * 1.2).r;
	COLOR.g = texture(SCREEN_TEXTURE, SCREEN_UV + distort * 1.0).g;
	COLOR.b = texture(SCREEN_TEXTURE, SCREEN_UV + distort * 0.8).b;
	COLOR.rgb *= (1. - discretize(4., eye_frame));
}
