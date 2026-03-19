shader_type canvas_item;

uniform float inner_radius : hint_range(0, 1) = 0.2;
uniform float outer_radius : hint_range(0, 2) = 1.25;
uniform float opacity : hint_range(0, 1) = 0.75;

void fragment() {
    vec2 centered = UV - vec2(0.5);
	float a = smoothstep(inner_radius, outer_radius, length(centered));
	COLOR = vec4(0, 0, 0, a * opacity);
}
