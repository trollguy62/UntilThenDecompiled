shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, diffuse_burley;

uniform vec4 albedo : source_color = vec4(1);
uniform sampler2D tex_albedo : source_color;
uniform bool falling = false;

varying flat float instance_id;

float randf(float s) {
    return fract(sin(dot(vec2(s, s) ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand_range(float s, float a, float b) {
	return randf(s) * (b - a) + a;
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 texturePointSmooth(sampler2D smp, vec2 uv) {
	vec2 pixel_size = 1.0f / vec2(textureSize(smp, 0));

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

mat4 rotationX( in float angle ) {
	mat4 M = mat4(1);
	M[1][1] = M[2][2] = cos(angle);
	M[2][1] = sin(angle);
	M[1][2] = -M[2][1];
	return M;
}

mat4 rotationY( in float angle ) {
	mat4 M = mat4(1);
	M[0][0] = M[2][2] = cos(angle);
	M[0][2] = sin(angle);
	M[2][0] = -M[0][2];
	return M;
}

mat4 rotationZ( in float angle ) {
	mat4 M = mat4(1);
	M[0][0] = M[1][1] = cos(angle);
	M[1][0] = sin(angle);
	M[0][1] = -M[1][0];
	return M;
}

void vertex() {
	instance_id = float(INSTANCE_ID);
	float nx = abs(UV.x - 0.5) * 2.;
	VERTEX += NORMAL * randf(instance_id) * abs(pow(nx, 2.3)) * 0.005;

	if (falling) {
		mat4 rot = rotationX(radians(30.))
			* rotationY(radians(rand_range(instance_id, -90., 90.)))
			* rotationZ(radians(sin(TIME * 20.) * 33.3));
		VERTEX = (vec4(VERTEX, 1) * rot).xyz;
		NORMAL = (vec4(NORMAL, 1) * rot).xyz;
	}
}

void fragment() {
	vec3 color = hsv2rgb(vec3(
		rand_range(instance_id, 16., 60.) / 360.,
		rand_range(instance_id, 0.5, 0.7),
		rand_range(instance_id, 0.4, 0.7)
	));

	vec4 albedo_tex = texturePointSmooth(tex_albedo, UV) * vec4(color, 1);
	ALBEDO = albedo_tex.rgb * albedo.rgb;
	ALPHA = albedo_tex.a * albedo.a;
}
