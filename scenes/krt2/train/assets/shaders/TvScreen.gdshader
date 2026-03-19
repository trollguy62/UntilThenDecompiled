shader_type spatial;

const vec2 PX_SIZE_FRAME = 1.0 / vec2(48, 28);

const vec2 PX_SIZE_MAIN = 1.0 / vec2(37, 18);
const vec2 PX_SIZE_BOTTOM = 1.0 / vec2(48, 7);
const vec2 PX_SIZE_TICKER = 1.0 / vec2(48, 3);
const vec2 PX_SIZE_TICKER_C = 1.0 / vec2(22, 1);
const vec2 PX_SIZE_SIDE = 1.0 / vec2(11, 18);

const vec2 POS_MAIN = vec2(11, 0);
const vec2 POS_BOTTOM = vec2(0, 21);
const vec2 POS_TICKER = vec2(0, 18);
const vec2 POS_TICKER_C = vec2(12, 19);
const vec2 POS_SIDE = vec2(0, 0);

const float FPS_MAIN = 4.5;
const float CYCLES_MAIN = 4.0;
const ivec2 FLIPBOOK_SIZE_MAIN = ivec2(3, 3);
const float FRAMES_MAIN = 9.0;
const int VARIANTS_MAIN = 2;

uniform sampler2D tex_bottom : source_color, filter_nearest;
uniform sampler2D tex_ticker : source_color, filter_nearest;

uniform sampler2D tex_ticker_c_1 : source_color, filter_nearest;
uniform sampler2D tex_ticker_c_2 : source_color, filter_nearest;
uniform sampler2D tex_ticker_c_3 : source_color, filter_nearest;

uniform sampler2D tex_side_1 : source_color, filter_nearest;
uniform sampler2D tex_side_2 : source_color, filter_nearest;
uniform sampler2D tex_side_3 : source_color, filter_nearest;
uniform sampler2D tex_side_4 : source_color, filter_nearest;
uniform sampler2D tex_side_5 : source_color, filter_nearest;

uniform sampler2D tex_main_1 : source_color, filter_nearest;
uniform sampler2D tex_main_2 : source_color, filter_nearest;

uniform float emission_mult = 1.0;

vec4 textureA(sampler2D smp, vec2 uv) {
	vec4 c = texture(smp, uv);
	return c * c.a;
}

void superimpose(inout vec4 c, vec2 px, sampler2D smp, vec2 uv, vec2 pos) {
	vec2 px_size = 1.0f / vec2(textureSize(smp, 0));
	vec2 end = pos + 1.0 / px_size;
	if (px.x >= pos.x && px.x < end.x && px.y >= pos.y && px.y < end.y)
		c += textureA(smp, uv * (px_size / PX_SIZE_FRAME) - pos * px_size);
}

void superimposeFlipbook(inout vec4 c, vec2 px, sampler2D smp, vec2 uv, vec2 pos, float t, ivec2 size, float fps) {
	vec2 px_size = 1.0 / vec2(textureSize(smp, 0));
	vec2 reg_size = (1.0 / px_size) / vec2(size);

	vec2 end = pos + reg_size;
	vec2 trans = pos;

	float frames = float(size.x * size.y);
	float n = floor(mod(fps * t, frames));
	float x = mod(n, float(size.x));
	float y = floor(n / float(size.x));
	trans -= vec2(x, y) * reg_size;

	if (px.x >= pos.x && px.x < end.x && px.y >= pos.y && px.y < end.y)
		c += textureA(smp, uv * (px_size / PX_SIZE_FRAME) - trans * px_size);
}

void drawTickerContent(inout vec4 c, vec2 px, vec2 uv, float t) {
	int ticker_c_pos_id = int(floor(abs(3.0 * sin(0.5 * t))));
	if (ticker_c_pos_id > 0) {
		int ticker_c_id = int(floor(t / (2.0 * PI))) % 3;
		vec2 pos_ticker_c = POS_TICKER_C;

		if (ticker_c_pos_id == 1) {
			int ticker_c_ori = int(floor(t / PI)) % 2;
			pos_ticker_c.y += ticker_c_ori == 0 ? 1.0 : -1.0;
		}

		switch (ticker_c_id) {
			case 0:
				superimpose(c, px, tex_ticker_c_1, uv, pos_ticker_c);
				break;
			case 1:
				superimpose(c, px, tex_ticker_c_2, uv, pos_ticker_c);
				break;
			case 2:
				superimpose(c, px, tex_ticker_c_3, uv, pos_ticker_c);
				break;
		}
	}
}

void drawSide(inout vec4 c, vec2 px, vec2 uv, float t) {
	int sideId = int(floor(t / 4.0)) % 5;
	switch (sideId) {
		case 0:
			superimpose(c, px, tex_side_1, uv, POS_SIDE);
			break;
		case 1:
			superimpose(c, px, tex_side_2, uv, POS_SIDE);
			break;
		case 2:
			superimpose(c, px, tex_side_3, uv, POS_SIDE);
			break;
		case 3:
			superimpose(c, px, tex_side_4, uv, POS_SIDE);
			break;
		case 4:
			superimpose(c, px, tex_side_5, uv, POS_SIDE);
			break;
	}
}

void drawMain(inout vec4 c, vec2 px, vec2 uv, float t) {
	float cycleTime = FRAMES_MAIN / FPS_MAIN;
	float variantTime = cycleTime * CYCLES_MAIN;
	int variantId = int(floor(mod(t, variantTime * float(VARIANTS_MAIN)) / variantTime));

	switch (variantId) {
		case 0:
			superimposeFlipbook(c, px, tex_main_1, uv, POS_MAIN, t, FLIPBOOK_SIZE_MAIN, FPS_MAIN);
			break;
		case 1:
			superimposeFlipbook(c, px, tex_main_2, uv, POS_MAIN, t, FLIPBOOK_SIZE_MAIN, FPS_MAIN);
			break;
	}

}

void fragment() {
	vec2 uv = UV;
	vec4 c = vec4(0);
	vec2 px = floor(uv / PX_SIZE_FRAME);

	superimpose(c, px, tex_bottom, uv, POS_BOTTOM);
	superimpose(c, px, tex_ticker, uv, POS_TICKER);

	drawTickerContent(c, px, uv, TIME);
	drawSide(c, px, uv, TIME);
	drawMain(c, px, uv, TIME);

	ALBEDO = vec3(0);
	EMISSION = c.rgb * emission_mult;
}
