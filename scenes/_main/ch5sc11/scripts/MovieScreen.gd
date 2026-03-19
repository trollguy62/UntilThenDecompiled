extends MeshInstance3D

@export var display_viewport_path: NodePath
@export var light_paths : Array[NodePath]

@export_range(0.0, 8.0) var light_energy = 1.0
@export_range(0.0, 1.0) var max_saturation = 0.6
@export_range(0.0, 1.0) var min_value = 0.2

@onready var display_viewport = get_node(display_viewport_path) as Viewport
@onready var display_tex = display_viewport.get_texture()
@onready var material = material_override as ShaderMaterial

@onready var avg_calc_viewport = $AverageCalc
@onready var avg_calc_input_mat = $AverageCalc/ColorRect.material as ShaderMaterial

var lights = []


func _ready():
	for p in light_paths:
		var light = get_node(p)
		assert(light is Light3D)
		lights.append(light)

	material.set_shader_parameter("texture_albedo", display_tex)
	avg_calc_input_mat.set_shader_parameter("input", display_tex)


func _process(_delta):
	var c = _get_average_color()
	for light in lights:
		light.light_color = c


func _get_average_color() -> Color:
	var data = avg_calc_viewport.get_texture().get_image().get_data()
	var c = Color8(data[8], data[9], data[10])

	c.s = min(c.s, max_saturation)
	c.v = max(c.v, min_value)
	c *= light_energy * Utils.sin_bounded(Utils.t, 0.975, 1.025, 10.0)
	return c
