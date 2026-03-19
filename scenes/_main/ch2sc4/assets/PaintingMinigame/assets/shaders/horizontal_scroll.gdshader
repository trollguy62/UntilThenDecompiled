shader_type canvas_item;

uniform float scroll_speed = 1.0;
uniform vec4 tint: source_color = vec4(1.0);

void fragment() {
	vec2 uv = UV;
	uv.x -= TIME * scroll_speed;
	vec4 color = texture(TEXTURE, uv) * tint;

	COLOR *= color;
}
