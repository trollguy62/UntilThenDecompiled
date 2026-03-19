@tool
extends MeshInstance3D

const SCALE_FACTOR = 100.0

@export var uv_scale = Vector2(1.0, 1.0):
	set(_scale):
		uv_scale = _scale
		(get_active_material(0) as ShaderMaterial).set_shader_parameter("scale", scale)

@export var texture: Texture:
	set(tex):
		texture = tex
		set_surface_override_material(0, get_surface_override_material(0).duplicate(true))
		(get_active_material(0) as ShaderMaterial).set_shader_parameter("tex", texture)
		mesh.center_offset = Vector3(texture.get_width() / (2.0 * SCALE_FACTOR), 0.0, 0.0)
		mesh.size = Vector2(texture.get_size() / SCALE_FACTOR)
@export var disabled = false

func _ready():
	texture = texture

func set_scale(_scale: Vector3):
	_scale.x = max(0.0, _scale.x)
	scale = _scale
	(get_active_material(0) as ShaderMaterial).set_shader_parameter("scale", scale)


func set_length(length: float):
	var target_scale = scale
	target_scale.x = length / mesh.size.x
	set_scale(target_scale)


func get_length() -> float:
	if mesh and mesh.size:
		assert(mesh.size)
		return mesh.size.x * scale.x
	return 0.0


func _input(event):
	if event.is_action_pressed("ui_end"):
		texture = texture
	if disabled:
		return
	if event.is_action_pressed("c_interact") or event.is_action_pressed("interact"):
		var target_scale = scale
		target_scale.x += 0.1
		set_scale(target_scale)
	if event.is_action_pressed("c_cancel"):
		var target_scale = scale
		target_scale.x -= 0.1
		set_scale(target_scale)
		uv_scale *= 1.1
