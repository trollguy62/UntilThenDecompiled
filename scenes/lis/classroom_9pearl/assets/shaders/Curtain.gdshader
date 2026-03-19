shader_type spatial;
render_mode depth_draw_always;

uniform vec4 albedo : source_color = vec4(1);
uniform vec4 transmission : source_color = vec4(0);
uniform sampler2D texture_albedo : source_color;
uniform sampler2D noise : hint_default_black;
uniform float strength : hint_range(0.01, 16) = 1.0;
uniform float y_damping : hint_range(0.01, 16) = 1.5;
uniform float speed = 1.0;

uniform vec3 displacement = vec3(0, 0, 1);
uniform float roughness : hint_range(0, 1) = 1.0;

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

float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float dt = rand(world_pos.yz * world_pos.x) * 6.96969;
	VERTEX += texture(noise, UV * 0.5 - vec2(TIME * speed * 0.2 + dt)).r * 0.1 * strength * pow(UV.y, y_damping) * displacement;
}

void fragment() {
	vec2 px_size = 1.0 / vec2(textureSize(texture_albedo, 0));
	vec4 tex_albedo = texturePointSmooth(texture_albedo, UV, px_size);

	ALBEDO = tex_albedo.rgb * albedo.rgb;
	ALPHA = tex_albedo.a * albedo.a;
	BACKLIGHT = transmission.rgb * transmission.a;
	ROUGHNESS = roughness;
}
