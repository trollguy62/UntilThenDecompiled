shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, depth_prepass_alpha, cull_disabled;

uniform float speed = 1.0;
uniform float strength : hint_range(0, 16.0) = 1.0;
uniform float damping : hint_range(0.01, 16.0) = 2.0;
uniform float vertical_exp : hint_range(0.01, 16.0) = 3.0;

uniform sampler2D variant_1 : source_color, repeat_disable;
uniform sampler2D variant_2 : source_color, repeat_disable;
uniform sampler2D variant_3 : source_color, repeat_disable;
uniform sampler2D noise_wind_x : hint_default_black;
uniform sampler2D noise_wind_y : hint_default_black;

varying flat float inst_id;

vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size) {
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);

	vec2 uv_pixels = uv / pixel_size;
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;

	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	uv = uv_pixels_floor * pixel_size;
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

mat4 rotationX(in float angle) {
	mat4 M = mat4(1);
	M[1][1] = M[2][2] = cos(angle);
	M[2][1] = sin(angle);
	M[1][2] = -M[2][1];
	return M;
}

vec2 variantTexSize(int id) {
	switch (id % 3) {
		case 0: return vec2(textureSize(variant_1, 0));
		case 1: return vec2(textureSize(variant_2, 0));
		case 2: return vec2(textureSize(variant_3, 0));
	}
}

vec4 variantTex(int id, vec2 uv, vec2 px_size) {
	switch (id % 3) {
		case 0: return texturePointSmooth(variant_1, uv, px_size);
		case 1: return texturePointSmooth(variant_2, uv, px_size);
		case 2: return texturePointSmooth(variant_3, uv, px_size);
	}
}

void vertex() {
	vec2 px_size = 1. / variantTexSize(INSTANCE_ID);
	inst_id = float(INSTANCE_ID);

	VERTEX -= vec3(0, 0, 0.005);
	VERTEX /= vec3(px_size.x, 1., px_size.y);
	VERTEX = (vec4(VERTEX, 1) * rotationX(PI / 2.)).xyz;

	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 wind_dir = vec2(
		texture(noise_wind_x, fract(world_pos * 0.05 + vec3(TIME * speed * 0.1)).xz).r,
		texture(noise_wind_y, fract(world_pos * 0.05 + vec3(TIME * speed * 0.1)).xz).r
	);
	vec2 wind_dir_d = pow(abs(2. * wind_dir - vec2(1.)), vec2(damping));
	wind_dir = mix(vec2(-1), vec2(1), step(wind_dir, vec2(0.5))) * wind_dir_d;

	vec2 wind_fac = wind_dir * strength * pow(1. - UV.y, vertical_exp);
	VERTEX += (vec4(wind_fac.x, 0, wind_fac.y, 1) * MODEL_MATRIX).xyz;
}

void fragment() {
	int id = int(inst_id);
	vec2 px_size = 1. / variantTexSize(id);
	vec4 tex = variantTex(id, UV, px_size);

	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}
