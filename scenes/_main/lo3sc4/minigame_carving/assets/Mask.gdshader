shader_type canvas_item;

uniform sampler2D tex_background : hint_default_transparent, filter_nearest;
uniform vec2 brush_pos = vec2(0.5);
uniform float brush_size = 0.04;

void fragment() {
	vec4 bg = texture(tex_background, UV);

	vec2 brush_uv = (UV - brush_pos) * vec2(16. / 9., 1.);
	float k = pow(1. - clamp(length(brush_uv) / brush_size, 0., 1.), 0.2);
	vec4 brush = vec4(
		1,
		step(k, 0.7) * 0.05,
		0,
		k
	);

	float alpha_over = brush.a + bg.a * (1. - brush.a);
	vec3 rgb_over = ((brush.rgb * brush.a) + (bg.rgb * bg.a * (1. - brush.a))) / alpha_over;
	COLOR = vec4(rgb_over, alpha_over);
}
