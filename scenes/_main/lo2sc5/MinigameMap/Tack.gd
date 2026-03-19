@tool
extends Area2D

signal selected
signal deselected

@export var texture: Texture2D:
	set(v):
		if not is_inside_tree():
			await ready
		$Sprite.texture = v
		texture = v

@export var id: int = 0

var _is_dragging = false
var start_pos = Vector2()

func _ready():
	start_pos = global_position

func _process(delta):
	if Engine.is_editor_hint():
		texture = texture
	if _is_dragging:
		global_position = get_viewport().get_mouse_position()

func set_input(enabled: bool):
	set_deferred("monitorable", enabled)
	_is_dragging = false
	input_pickable = enabled

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if shape_idx == 0:
			#collision
			pass
		if shape_idx == 1:
			#pickup
			_is_dragging = event.is_pressed()
			if event.is_pressed():
				selected.emit()
			else:
				deselected.emit()
