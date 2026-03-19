shader_type canvas_item;
render_mode blend_mix;


uniform float saturation: hint_range(0.0, 2.0) = 1.0;
uniform float brightness: hint_range(0.0, 2.0) = 1.0;
uniform float contrast: hint_range(0.0, 2.0) = 1.0;
uniform float hue: hint_range(0.0, 360.0) = 0.0;

vec3 hueShift(vec3 color, float hue_){
	const vec3 k = vec3(0.57735);
	float cosAngle = cos(hue_);
	return vec3(color * cosAngle + cross(k, color) * sin(hue_) + k * dot(k, color) * (1.0 - cosAngle));
}

void fragment(){
	vec4 col = texture(TEXTURE, UV);
	float pseudo_alpha = (col.r + col.g + col.b) / 3.0;

	float hue_in_rad = hue * PI / 180.0;
	col.rgb = hueShift(col.rgb, hue_in_rad);
	col.rgb = mix(vec3(dot(col.rgb, vec3(0.2126 , 0.7152 , 0.0722))), col.rgb, saturation);
	col.rgb = clamp(col.rgb + (brightness - 1.0), vec3(0.0), vec3(1.0));
	//col.rgb = mix(vec3(0.0), col.rgb, brightness);
	col.rgb = mix(vec3(0.5), col.rgb, contrast);

	COLOR = col;
}
