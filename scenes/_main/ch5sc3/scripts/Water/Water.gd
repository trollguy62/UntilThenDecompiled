extends Node3D

@export var wave_amplitude = 0.1
@export var wave_height_fac = 4.0

@onready var mesh = $Mesh
@onready var cr = $Simulation/ColorRect
@onready var sim_tex = $Simulation.get_texture()
@onready var col_tex = $Collision.get_texture()

var surface_data: PackedByteArray


func _ready():
	cr.material.set_shader_parameter("sim_tex", sim_tex)
	cr.material.set_shader_parameter("col_tex", col_tex)

	mesh.material_override.set_shader_parameter("simulation", sim_tex)
	mesh.material_override.set_shader_parameter("simulation2", sim_tex)


func _physics_process(delta):
	var sim_img = sim_tex.get_image()

	surface_data = sim_img.get_data()

	var newtex = ImageTexture.create_from_image(sim_img)

	cr.material.set_shader_parameter("sim_tex", newtex)
	mesh.material_override.set_shader_parameter("amplitude", wave_amplitude)


func get_height(global_pos):
	var height = mesh.global_transform.origin.y

	if surface_data.is_empty():
		return height

	var local_pos = mesh.to_local(global_pos)

	var water_size = Vector2(0.24, 0.21)
	var grid_size = Vector2(290, 256)

	var x = int((local_pos.x + water_size.x / 2.0) / water_size.x * (grid_size.x))
	var y = grid_size.y - int((local_pos.z + water_size.y / 2.0) / water_size.y * (grid_size.y))

	if x > grid_size.x - 1 or y > grid_size.y - 1 or x < 0 or y < 0:
		return -99999.9

	var i = 4 * (y * (grid_size.x) + x)

	if (i+1 >= surface_data.size()):
		return height

	height += (surface_data[i] - surface_data[i + 1]) / 255.0 * wave_amplitude * wave_height_fac
	return height
