@tool
extends MeshInstance3D

const WHEEL_RADIUS = 0.42
const WHEEL_CIRCUMFERENCE = 2 * PI * WHEEL_RADIUS

const ALT_WINDOW_COLOR = Color("e6daf6ff")
const ALT_WINDOW_TEX = preload("res://assets/ui/hint_white.png")

@export_range(-16.0, 16.0) var speed = 0.0  # px/s
@export var use_alt_windows = false : set = set_use_alt_windows

@onready var wheels = $Wheels.get_children()

var _windows_mat_data = {}  # Map<int, [Color, Texture]>


func _ready():
	for window in $Windows.get_children():
		var mat = window.material_override as ShaderMaterial
		var id = mat.get_instance_id()
		var albedo = mat.get_shader_parameter("albedo") as Color
		var tex_albedo = mat.get_shader_parameter("texture_albedo") as Texture
		_windows_mat_data[id] = [albedo, tex_albedo]

	if use_alt_windows:
		set_use_alt_windows(true)


func _process(delta):
	if wheels != null:
		for wheel in wheels:
			var rots_per_sec = speed / WHEEL_CIRCUMFERENCE
			wheel.rotate_z(rots_per_sec * 2 * PI * delta)


func set_use_alt_windows(value):
	use_alt_windows = value

	if is_inside_tree():
		for id in _windows_mat_data:
			var data = _windows_mat_data[id]
			var mat = instance_from_id(id) as ShaderMaterial
			mat.set_shader_parameter("albedo", ALT_WINDOW_COLOR if use_alt_windows else data[0])
			mat.set_shader_parameter("texture_albedo", ALT_WINDOW_TEX if use_alt_windows else data[1])
