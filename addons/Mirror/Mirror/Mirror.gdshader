shader_type spatial;
render_mode cull_disabled;

uniform vec4 tint : source_color = vec4(vec3(0.98),1.0);
uniform sampler2D mirror_tex : source_color, repeat_disable, filter_nearest;
uniform sampler2D distort_tex : source_color;
uniform sampler2D override_tex : source_color, hint_default_white, filter_nearest;
uniform float distort_strength : hint_range(0, 30);

void fragment() {
	vec2 m_UV = UV;

	// Backface texcoord flip correction
	if (FRONT_FACING) {
		m_UV.x = 1.0 - m_UV.x;
	}

	float distort_ofs = texture(distort_tex, m_UV).r;
	// Map offset to [-1, 1] region
	distort_ofs = (distort_ofs * 2.0) - 1.0;
	vec2 distort_ofs_uv = distort_ofs * distort_strength / VIEWPORT_SIZE;

	vec4 mirror_sample = texture(mirror_tex, m_UV + distort_ofs_uv);
	vec4 override_sample = texture(override_tex, UV + distort_ofs_uv);
	ALBEDO = tint.rgb * mirror_sample.rgb * override_sample.rgb;
	ALPHA = override_sample.a;
}
