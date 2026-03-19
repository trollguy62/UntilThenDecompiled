@tool
extends Line2D


func _process(delta):
	if points.size() != 2:
		return
	var d = points[1] - points[0]
	var angle = atan2(d.y, d.x)
	material.set_shader_parameter("angle", angle)
