@tool
extends MeshInstance3D

const TVScreenMat = preload("res://scenes/_main/ch5sc9/assets/envi/materials/TVScreen.material")

@export var viewport_path : NodePath : set = set_viewport_path
@export_range(0.0, 1.0) var power = 1.0
@export_range(0.0, 1.0) var static_blend = 0.0

@onready var light = $Light
@onready var tween = Threen.new()

var mat_screen: ShaderMaterial


func _ready():
	add_child(tween)
	mat_screen = TVScreenMat.duplicate()
	set_surface_override_material(1, mat_screen)

	await get_tree().process_frame
	self.viewport_path = viewport_path


func _process(_delta):
	mat_screen.set_shader_parameter("power", power)
	mat_screen.set_shader_parameter("static_blend", static_blend)

	light.visible = power >= 0.01
	light.light_energy = 4.0 * pow(power, 2.0)


func _get_configuration_warning():
	if not get_node(viewport_path) is Viewport:
		return "Invalid viewport path"
	return ""


func tv_power(on: float, duration: float = 0.2):
	tween.interpolate_property(self, "power", power, 1.0 if on else 0.0 , duration)
	tween.start()


func set_viewport_path(value: NodePath):
	viewport_path = value

	if is_inside_tree():
		var viewport = get_node(viewport_path)
		assert(viewport is Viewport)

		var viewport_tex = viewport.get_texture()
		mat_screen.set_shader_parameter("display", viewport_tex)
