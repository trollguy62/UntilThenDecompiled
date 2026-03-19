shader_type spatial;
render_mode cull_disabled, unshaded, blend_add;

uniform sampler2D doftex : filter_linear;
uniform float focal_plane : hint_range(0, 10);
uniform float aperture : hint_range(0, 1);
uniform float dist : hint_range(1, 100) = 5.0;
uniform float strength : hint_range(0.001, 1) = 1.0;

void vertex() {
	// this enables particle billboard mode
	mat4 mat_world = mat4(normalize(INV_VIEW_MATRIX[0])*length(MODEL_MATRIX[0]),normalize(INV_VIEW_MATRIX[1])*length(MODEL_MATRIX[0]),normalize(INV_VIEW_MATRIX[2])*length(MODEL_MATRIX[2]),MODEL_MATRIX[3]);
	mat_world = mat_world * mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x),0.0,0.0), vec4(sin(INSTANCE_CUSTOM.x),cos(INSTANCE_CUSTOM.x),0.0,0.0),vec4(0.0,0.0,1.0,0.0),vec4(0.0,0.0,0.0,1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
}

void fragment() {
	float x = min(1, length(UV - vec2(0.5, 0.5))*dist);

	if (x >= 1.0 - 1e-9)
		discard;

	float y = abs(VERTEX.z + focal_plane) * aperture;
	ALBEDO = texture(doftex, vec2(x,y)).rgb * vec3(1,1,1) * 0.1 * strength * COLOR.rgb;
}
