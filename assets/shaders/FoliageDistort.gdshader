shader_type spatial;
render_mode diffuse_burley, depth_prepass_alpha, cull_disabled;

uniform sampler2D tex_albedo : source_color, filter_nearest, repeat_disable;
uniform sampler2D tex_noise;
uniform sampler2D tex_influence : hint_default_white;

uniform vec2 speed = vec2(1);
uniform vec2 uniformity = vec2(1);
uniform vec2 strength = vec2(1);
uniform float damping = 2.0;
uniform float time_offset = 0.0;

void fragment() {
	float t = TIME + time_offset;
	vec2 uv = UV;

	vec2 D = vec2(0);
	D.x = texture(tex_noise, uv * uniformity + vec2(0.3, 0.2) * t * speed.x).r;
	D.y = texture(tex_noise, uv * uniformity + vec2(0.11, 0.5) * t * speed.y).r;
	D *= texture(tex_influence, uv).r;
	D = pow(D, vec2(damping));

	vec2 px_size = 1.0 / vec2(textureSize(tex_albedo, 0));
	uv -= D * px_size * strength;

	vec4 c = texture(tex_albedo, uv);
	//c = vec4(uv, 0, 1);
	//c = vec4(D, 0, 1);

	ALBEDO = c.rgb;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.01;
}
