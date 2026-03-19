shader_type canvas_item;

uniform float scroll_speed = 1.0;

void fragment() {
	vec2 uv = UV;
	uv.x *= TIME;
	COLOR = texture(TEXTURE, vec2(UV.x + TIME * scroll_speed, UV.y));
}
