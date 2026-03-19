extends Node

@export var pivot_path: NodePath

@onready var control = $CanvasLayer/Control
@onready var canvas_layer = $CanvasLayer
@onready var tween = Threen.new()

var _control_pos = Vector2.ZERO
var _pivot: Node
var is_active = false


func _ready():
	add_child(tween)
	_pivot = get_node(pivot_path)
	_update_control()
	control.modulate.a = 0


func _process(delta):
	_update_control()


func show():
	if is_active:
		return

	tween.interpolate_property(control, "modulate:a", 0.0, 1.0, 0.5)
	tween.start()
	is_active = true


func hide():
	if not is_active:
		return

	tween.interpolate_property(control, "modulate:a", 1.0, 0.0, 0.5)
	tween.start()
	is_active = false


func _update_control():
	_update_control_position()


func _update_control_position():
	if _pivot != null:
		var viewport = get_viewport()
		var camera = viewport.get_camera_3d()
		var is_behind = false

		if _pivot is Marker3D and camera != null:
			var world_pos = _pivot.global_transform.origin
			_control_pos = camera.unproject_position(world_pos)
			is_behind = (
				camera.global_transform.basis.z.dot(world_pos - camera.global_transform.origin)
				>= 0
			)

		control.position = _control_pos
	else:
		control.position = Vector2(-999, -999)
