shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tex : source_color;
uniform vec2 scale = vec2(1.0f);
uniform bool flip = false;

void fragment() {
	vec2 uv = UV;
	uv.x = flip ? 1.0 - UV.x : UV.x;

	vec4 tex_t = texture(tex, vec2(scale.x * (uv.x), scale.y * UV.y));
	ALBEDO = tex_t.rgb;
	ALPHA = tex_t.a;
}
