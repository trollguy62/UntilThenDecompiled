shader_type canvas_item;

uniform float t : hint_range(0, 1);
uniform sampler2D tex_1;
uniform sampler2D tex_2;

void fragment() {
	COLOR = mix(
		texture(tex_1, UV),
		texture(tex_2, UV),
		t
	);
}
