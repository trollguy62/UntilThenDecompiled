extends Node3D

@export var textures : Array[Texture]

@onready var parts = [$Body,$WheelBL,$WheelBR,$WheelFL,$WheelFR]
@onready var right_wheel = $WheelFR
@onready var left_wheel = $WheelFL
@onready var body_mesh = $Body


func set_variation(val, s_mat):
	for part in parts:
		s_mat.set_shader_parameter("albedo", textures[val])
		part.set_surface_override_material(0, s_mat)


func get_random_variation():
	var random_num = randi() % textures.size()
	return random_num


func rotate_wheels(rotate_input):
	right_wheel.rotation.y = rotate_input
	left_wheel.rotation.y = rotate_input


func rotate_body(delta, t):
	body_mesh.rotation.y = lerp(body_mesh.rotation.z, t, 10 * delta)
