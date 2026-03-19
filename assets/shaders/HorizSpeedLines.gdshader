shader_type canvas_item;

uniform sampler2D tex_noise : source_color, filter_linear, repeat_enable;
uniform float speed = 1.0;

void fragment() {
	float c = texture(tex_noise, UV / vec2(8, 1) - vec2(TIME * speed, 0)).r;
	c = pow(c, 1.4);
	COLOR *= c;
}
