extends Control

const FocusableControl = preload("res://ui/components/Game/FocusableControl.gd")

@export var persist_focus := false
@export var focus_on_enter: Control

var _page_container
var _persist_focus_control: Control


func _enter():
	_release_current_focus()

	var new_focus: Control

	if persist_focus and _persist_focus_control != null:
		new_focus = _persist_focus_control
	else:
		new_focus = focus_on_enter

	if new_focus != null:
		if new_focus is FocusableControl:
			new_focus.mute_next_tick_only = true
		new_focus.call_deferred("grab_focus")


func _exit():
	if persist_focus:
		_persist_focus_control = get_viewport().gui_get_focus_owner()

	_release_current_focus()


func _release_current_focus():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()
