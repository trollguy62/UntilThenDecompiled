shader_type spatial;
render_mode depth_prepass_alpha, diffuse_burley, specular_schlick_ggx, cull_disabled;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D texture_albedo : source_color, filter_linear;
uniform float alpha_scissor : hint_range(0, 1) = 1.0f;

uniform sampler2D texture_normal : hint_normal, filter_linear;
uniform float normal_depth = 1.0f;
uniform bool normal_linear_sampling = false;

uniform float metallic : hint_range(0, 1) = 0.0f;
uniform float roughness : hint_range(0, 1) = 1.0f;
uniform float specular : hint_range(0, 1) = 0.5f;
uniform sampler2D texture_roughness_metallic : hint_default_white, filter_linear;

uniform vec4 emission : source_color = vec4(0, 0, 0, 1);
uniform float emission_energy : hint_range(0, 16) = 1.0f;
uniform float emission_saturation : hint_range(0, 8) = 1.0f;
uniform sampler2D texture_emission : hint_default_black, filter_linear;
uniform bool emission_blend_add = true;

uniform sampler2D texture_glow : filter_linear;
uniform vec4 glow_color : source_color = vec4(0, 0, 0, 1);

uniform vec4 transmission : source_color = vec4(0, 0, 0, 1);

uniform sampler2D texture_displacement;
uniform float displacement_strength = 0.;

uniform sampler2D texture_wet : hint_default_black, filter_linear;
uniform float wet_metallic : hint_range(0, 1) = 0.5;
uniform bool wet_linear_sampling = false;

uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_scale_mult = vec3(1.0);
uniform vec3 uv1_offset;

uniform bool y_billboard = false;

void vertex() {
	if (y_billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],MODEL_MATRIX[1],vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz,MODEL_MATRIX[1].xyz)), 0.0),MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, 1.0, 0.0, 0.0),vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}

	UV = UV * uv1_scale.xy * uv1_scale_mult.xy + uv1_offset.xy;
	VERTEX += NORMAL * texture(texture_displacement, UV).r * displacement_strength;
}

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

vec3 saturate(vec3 color, float amount) {
    vec3 gray = vec3(dot(vec3(0.2126, 0.7152, 0.0722), color));
    return clamp(vec3(mix(color, gray, 1.0 - amount)), vec3(0), vec3(1));
}

void fragment() {
	vec2 px_size = 1.0f / vec2(textureSize(texture_albedo, 0));

	vec4 albedo_tex = texturePointSmooth(texture_albedo, UV, px_size);
	vec4 wet_tex = wet_linear_sampling
		? texture(texture_wet, UV)
		: texturePointSmooth(texture_wet, UV, px_size);

	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;

	vec2 roughness_metallic_tex = texturePointSmooth(texture_roughness_metallic, UV, px_size).rg;
	ROUGHNESS = roughness_metallic_tex.r * roughness * mix(1.0, 0.0, wet_tex.r);
	METALLIC = mix(roughness_metallic_tex.g * metallic, wet_metallic, wet_tex.r);

	NORMAL_MAP = normal_linear_sampling
		? texture(texture_normal, UV).rgb
		: texturePointSmooth(texture_normal, UV, px_size).rgb;
	NORMAL_MAP_DEPTH = normal_depth * (1.0 - wet_tex.g);
	SPECULAR = specular;

	vec4 emission_tex = texturePointSmooth(texture_emission, UV, px_size);
	vec4 glow_tex = texturePointSmooth(texture_glow, UV, px_size);

	vec3 emission_c1 = emission_tex.rgb * emission_tex.a;
	vec3 emission_c2 = emission.rgb * emission.a;
	vec3 emission_all = emission_blend_add ? emission_c1 + emission_c2 : emission_c1 * emission_c2;
	emission_all = saturate(emission_all, emission_saturation);

	vec3 emission_glow = albedo_tex.rgb * glow_tex.rgb * glow_color.rgb * glow_color.a;
	EMISSION = emission_all * emission_energy + emission_glow;

	BACKLIGHT = transmission.rgb * transmission.a;
}
