shader_type spatial;
render_mode cull_disabled;

uniform sampler2D sheet_tex : source_color;
uniform ivec2 sheet_size = ivec2(1, 1);
uniform vec2 pivot_offset = vec2(0);
uniform float y_float_extent = 0.05;

uniform bool controlled = false;
uniform int controlled_inst_id = 0;
uniform float controlled_phase : hint_range(0, 1) = 0.0;

varying flat int inst_id;
varying flat float phase;

void vertex() {
	if (controlled) {
		inst_id = controlled_inst_id;
		phase = controlled_phase;
	} else {
		inst_id = INSTANCE_ID;
		phase = INSTANCE_CUSTOM.y;
	}

	vec2 px_size = vec2(textureSize(sheet_tex, 0));

	VERTEX.xy += pivot_offset;
	VERTEX.xy *= px_size / vec2(100.0) / vec2(sheet_size);
	VERTEX.y += sin(TIME + float(INSTANCE_ID) * 0.03) * y_float_extent;
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

vec4 alphaComposite(vec4 Ca, vec4 Cb) {
	float a0 = Ca.a + (Cb.a * (1. - Ca.a));
	return (Ca * Ca.a + Cb * Cb.a * (1. - Ca.a)) / a0;
}

float R21(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 px_size = 1.0f / vec2(textureSize(sheet_tex, 0));

	int sheet_idx = inst_id % (sheet_size.x * sheet_size.y);
	ivec2 sheet_coord = ivec2(
		sheet_idx % sheet_size.x,
		sheet_idx / sheet_size.x
	);

	vec2 uv = (UV / vec2(sheet_size)) + (vec2(sheet_coord) / vec2(sheet_size));

	vec4 tex = texturePointSmooth(sheet_tex, uv, px_size);

	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 1.0;

	float glitch_fac = (pow(2.0 * phase - 1.0, 2.0));

	vec2 texs = vec2(textureSize(sheet_tex, 0));
	vec2 uvg = floor(UV * texs) / texs;
	float static = R21(uvg + vec2(TIME * 0.01));
	ALBEDO = alphaComposite(vec4(vec3(static), glitch_fac), vec4(ALBEDO, ALPHA)).rgb;

	if (glitch_fac >= 0.999) {
		ALPHA = 0.0;
	} else if (glitch_fac > 0.5) { // I know I know, `if` in a shader, scary
		ALPHA *= step(static, (1.0 - glitch_fac) / (1.0 - 0.5));
	}
}
