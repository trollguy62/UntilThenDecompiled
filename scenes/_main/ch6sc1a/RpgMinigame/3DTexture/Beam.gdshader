shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tex : filter_nearest;
uniform vec2 scale = vec2(1.0f);
uniform bool flip = false;
uniform bool animated = false;
uniform float animation_scale = .3;

void fragment() {
	vec2 uv = UV;
	float t = mod(TIME, 20.0);
	uv.x = flip ? 1.0 - UV.x : UV.x;
	uv.x -= t * animation_scale;

	vec4 tex_t = texture(tex, vec2(scale.x * (uv.x), scale.y * UV.y));
	ALBEDO = tex_t.rgb;
	ALPHA = tex_t.a;
}
