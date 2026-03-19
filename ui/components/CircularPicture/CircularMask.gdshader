shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
	float c = smoothstep(0.5, 0.49, length(UV - vec2(.5)));
	COLOR = texture(tex, UV) * vec4(1, 1, 1, c);
}
