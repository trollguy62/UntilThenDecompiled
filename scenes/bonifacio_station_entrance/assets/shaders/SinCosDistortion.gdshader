shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;

uniform sampler2D tex_shadow : source_color;
uniform float alpha_scissor : hint_range(0, 1) = 0.01;

uniform vec2 speed = vec2(0., 1.);
uniform vec2 frequency = vec2(0, 2.);
uniform vec2 amplitude = vec2(0.01);

void fragment() {
	vec2 uv = UV - vec2(
		cos(UV.y * frequency.x + TIME * speed.x),
		sin(UV.x * frequency.y + TIME * speed.y)
	) * amplitude;

	vec4 c = texture(tex_shadow, uv);
	ALBEDO = c.rgb;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}
