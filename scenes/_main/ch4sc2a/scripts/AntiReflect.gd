@tool
extends ReflectionProbe


func _process(delta):
	var env = get_world_3d().environment
	ambient_color = env.ambient_light_color
	ambient_color_energy = env.ambient_light_energy
