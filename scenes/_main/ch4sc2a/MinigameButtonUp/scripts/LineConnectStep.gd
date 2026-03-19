extends Node2D

signal connected(correct)

const TARGET_PREFIX = "HintTarget"

@export var correct_idx := 0
@export var focus_path : NodePath

@onready var line = $Line
@onready var hint_source = $HintSource
@onready var focus = get_node(focus_path) as Focus

var _targets := []
var _dragging := false
var _drag_start := Vector2()


func _ready():
	line.points = PackedVector2Array()
	for child in get_children():
		if child.name.begins_with(TARGET_PREFIX):
			_targets.push_back(child)


func _process(delta):
	if not is_visible_in_tree():
		return

	hint_source.visible = focus.active

	for target in _targets:
		target.visible = _dragging

	if _dragging:
		line.points = PackedVector2Array([_drag_start, get_global_mouse_position()])
	else:
		line.points = PackedVector2Array()


func _input(ev):
	if not is_visible_in_tree():
		return

	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed and not _dragging:
			if Utils.is_mouse_on_control(hint_source):
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
			connected.emit(i ==correct_idx)
			break
	_dragging = false
