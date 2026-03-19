shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tex : filter_nearest;
uniform vec2 scale = vec2(1.0f);

void fragment() {
	vec4 tex_t = texture(tex, vec2(scale.x * (1.0f - UV.x), scale.y * UV.y));
	ALBEDO = tex_t.rgb;
	ALPHA = tex_t.a;
}
