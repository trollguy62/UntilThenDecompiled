extends Node
class_name Focus

signal active_changed(active)

@export var focus_name := Constants.UNIVERSAL_FOCUS
@export var push_on_ready := false

var active := false


func _ready():
	active = is_active()
	FocusManager.focus_changed.connect(_on_focus_changed)

	if push_on_ready:
		push()


func push() -> bool:
	return FocusManager.push_focus(focus_name)


func pop() -> bool:
	return FocusManager.pop_focus(focus_name)


func is_active() -> bool:
	return FocusManager.is_focused(focus_name)


func _on_focus_changed():
	var new_active = is_active()
	if active != new_active:
		active = new_active
		active_changed.emit(active)
