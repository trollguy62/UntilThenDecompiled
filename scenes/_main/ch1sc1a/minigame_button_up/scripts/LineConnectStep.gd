extends Node2D

signal connected(target_idx)

const TARGET_PREFIX = "HintTarget"

var enabled = true

var _targets := []
var _dragging := false
var _drag_start := Vector2()


func _ready():
	$Line.points = PackedVector2Array()
	for child in get_children():
		if child.name.begins_with(TARGET_PREFIX):
			_targets.push_back(child)


func _process(delta):
	if not is_visible_in_tree():
		return

	$HintSource.visible = enabled and not _dragging
	for target in _targets:
		target.visible = _dragging

	if _dragging:
		$Line.points = PackedVector2Array([_drag_start, get_global_mouse_position()])
	else:
		$Line.points = PackedVector2Array()


func _input(ev):
	if not is_visible_in_tree():
		return

	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed and not _dragging:
			if Utils.is_mouse_on_control($HintSource):
				_start_drag()
		elif not ev.pressed and _dragging:
			_on_release()


func _start_drag():
	_dragging = true
	_drag_start = get_global_mouse_position()


func _on_release():
	for i in range(_targets.size()):
		var target = _targets[i] as Control
		if Utils.is_mouse_on_control(target):
			connected.emit(i)
			break
	_dragging = false
