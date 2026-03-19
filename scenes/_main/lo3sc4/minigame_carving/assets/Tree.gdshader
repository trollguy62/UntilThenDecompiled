shader_type canvas_item;

uniform vec4 modulate : source_color = vec4(1);
uniform sampler2D tex_tree : filter_nearest;
uniform sampler2D tex_carved : filter_nearest, repeat_enable;
uniform sampler2D tex_mask : filter_nearest, hint_default_black;

void make_kernel(inout vec4 n[9], sampler2D tex, vec2 px_size, vec2 uv) {
	n[0] = texture(tex, uv + px_size * vec2(-1, -1));
	n[1] = texture(tex, uv + px_size * vec2( 0, -1));
	n[2] = texture(tex, uv + px_size * vec2( 1, -1));
	n[3] = texture(tex, uv + px_size * vec2(-1,  0));
	n[4] = texture(tex, uv);
	n[5] = texture(tex, uv + px_size * vec2( 1,  0));
	n[6] = texture(tex, uv + px_size * vec2(-1,  1));
	n[7] = texture(tex, uv + px_size * vec2( 0,  1));
	n[8] = texture(tex, uv + px_size * vec2( 1,  1));
}

vec4 sobel(sampler2D tex, vec2 uv) {
	vec4 n[9];
	vec2 px_size = 1.0 / vec2(textureSize(tex, 0));
	make_kernel(n, tex_mask, px_size, uv);

	vec4 sobel_edge_h = n[2] + (2.0*n[5]) + n[8] - (n[0] + (2.0*n[3]) + n[6]);
  	vec4 sobel_edge_v = n[0] + (2.0*n[1]) + n[2] - (n[6] + (2.0*n[7]) + n[8]);
	return sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
}

void fragment() {
	vec2 uv_carved = UV * vec2(textureSize(tex_tree, 0)) / vec2(textureSize(tex_carved, 0));

	vec4 tree = texture(tex_tree, UV);
	vec3 mask = texture(tex_mask, UV).rgb * tree.a;
	vec4 carved = texture(tex_carved, uv_carved);
	vec4 outline = sobel(tex_mask, UV);

	COLOR = mix(
		tree * vec4(vec3(1.0 - pow(min(outline.r, 1.0), 50.0) * 0.15), 1),
		carved * vec4(vec3(1. - mask.g), 1.),
		mask.r
	) * modulate;
}
