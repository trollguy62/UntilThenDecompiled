extends Node

const InteractiveArea = preload("res://components/InteractiveArea/InteractiveArea.gd")
@export var enabled = true:
	set(value):
		if enabled != value:
			enabled = value
			_update()

@onready var focus = Focus.new()

var _active_stack = []
var _last_active


func _ready():
	add_child(focus)
	self.enabled = focus.active
	focus.active_changed.connect(_on_focus_active_changed)


func _on_focus_active_changed(active):
	self.enabled = active


func push(area: InteractiveArea):
	if not area in _active_stack:
		_active_stack.push_front(area)
		_update()


func pop(area: InteractiveArea):
	if area in _active_stack:
		_active_stack.erase(area)
		_update()


func _input(ev: InputEvent):
	if ev.is_action_pressed("interact") and _last_active != null:
		var interactive = _last_active
		var call = await interactive.interact()


func _update():
	# TODO i hate this. brittle and confusing logic. refactor this!
	# also like this and InteractiveArea are strongly coupled
	if not enabled:
		if _last_active != null:
			_last_active.hide()
			_last_active = null  # may not get popped ffs
		return

	var next_active = null if _active_stack.is_empty() else _active_stack.front()

	if _last_active != next_active:
		if _last_active != null:
			_last_active.hide()
		if next_active != null and next_active.is_enabled():
			next_active.show()

	_last_active = next_active
