extends Sprite2D

signal drag_start
signal drag_stop
signal clicked

@export var enabled := true
@export var bring_to_front_on_drag := false

@onready var area = Utils.get_child_of_type(self, "Area2D") as Area2D

var _dragging := false
var _mouse_entered := false
var _was_moved := false
var _dissolving := false


func _ready():
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)


func _input(ev: InputEvent):
	if not enabled or _dissolving or is_queued_for_deletion():
		return

	if ev is InputEventMouseButton:
		_dragging = ev.pressed and _mouse_entered

		if _dragging:
			get_viewport().set_input_as_handled()
			drag_start.emit()

			if bring_to_front_on_drag:
				_bring_to_front()

		if not ev.pressed and _mouse_entered:
			get_viewport().set_input_as_handled()

			if not _was_moved:
				clicked.emit()

			drag_stop.emit()
			_dragging = false
			_was_moved = false

	elif ev is InputEventMouseMotion and _dragging:
		if get_viewport_rect().has_point(get_global_mouse_position()):
			translate(ev.relative / global_scale)
			_was_moved = true
		else:
			_dragging = false
			_was_moved = false


func _bring_to_front():
	var parent = get_parent()
	var position = parent.get_child_count() - 1
	parent.move_child(self, position)


func _on_mouse_entered():
	_mouse_entered = true


func _on_mouse_exited():
	_mouse_entered = false
