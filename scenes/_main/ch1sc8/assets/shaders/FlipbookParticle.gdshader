shader_type spatial;
render_mode depth_draw_always;

uniform vec4 color : source_color = vec4(1, 1, 1, 1);
uniform float metallic : hint_range(0, 1) = 0;
uniform float roughness : hint_range(0, 1) = 1;

uniform sampler2D spritesheet;
uniform int h_frames : hint_range(1, 99) = 1;
uniform int v_frames : hint_range(1, 99) = 1;

uniform bool y_billboard = false;

vec4 texture_point_smooth(sampler2D smp, vec2 uv) {
	vec2 pixel_size = 1. / vec2(textureSize(smp, 0));
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

void vertex() {
	if (y_billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],MODEL_MATRIX[1],vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz,MODEL_MATRIX[1].xyz)), 0.0),MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
	}

	float lt = INSTANCE_CUSTOM.y;
	float hf = float(h_frames);
	float vf = float(v_frames);
	float frames = hf * vf;

	float i = floor(frames * lt);
	float x = mod(i, hf);
	float y = floor(i / hf);

	UV /= vec2(hf, vf);
	UV.x += x / hf;
	UV.y += y / hf;
}

void fragment() {
	vec4 tex = texture_point_smooth(spritesheet, UV) * color;
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}
