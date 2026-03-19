shader_type canvas_item;

const int SampleCount = 64; // use a multiple of 2 here
uniform float intensity = 0.1;
uniform vec2 mouse_position = vec2(0, 0);

float circle(in vec2 st, in float radius){
    vec2 dist = st-vec2(0.5);
	return 1.-smoothstep(radius-(radius*0.01),
                         radius+(radius*0.01),
                         dot(dist,dist)*4.0);
}

vec4 directionalBlur(in sampler2D tex, in vec2 uv, in vec2 direction, in float d_intensity)
{
    vec4 color = vec4(0.0);

    for (int i=1; i<=SampleCount; i++)
    {
        color += texture(tex,uv+float(i)*d_intensity/float(SampleCount)*direction);
    }

    return color/float(SampleCount);
}

vec4 mainImage(in sampler2D tex, vec2 uv, vec2 resolution, vec2 focus, in vec4 fragCoord )
{
    vec2 middle = resolution.xy * 0.5;

    vec2 direction = focus - fragCoord.xy;
	float aspect = resolution.x / resolution.y;
	vec2 circ_uv = (direction.xy) / resolution;
	circ_uv.x *= aspect;
	float edge0 = distance(circ_uv, vec2(0.3));
	float edge1 = distance(circ_uv, vec2(0.31));
	float circle = smoothstep(edge0, edge1, 0.3);
	// * (1.0 - direction)
	float dist = length(direction) / length(middle);
	vec4 color;
	float m_x = focus.x / resolution.x;
	float m_y = focus.y / resolution.y;
	color = directionalBlur(tex, uv, normalize(direction), dist * intensity);

	return color;
}

void fragment() {
	vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 uv = UV;

	vec4 color = vec4(0.0);

	color = mainImage(TEXTURE, UV, resolution, mouse_position, FRAGCOORD);

	COLOR = color;
}
