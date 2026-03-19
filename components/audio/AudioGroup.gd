extends Node3D
class_name AudioGroup

enum PlayEventTrigger { None, OnReady, OnShow }
enum HoldEventTrigger { None, OnHide }

@export var play_event: PlayEventTrigger
@export var stop_event: HoldEventTrigger


func _ready():
	if play_event == PlayEventTrigger.OnReady:
		play()

	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed():
	var visible = is_visible_in_tree()
	if visible and play_event == PlayEventTrigger.OnShow:
		play()
	elif not visible and stop_event == HoldEventTrigger.OnHide:
		stop()


func _exit_tree():
	stop()


func play():
	for child in get_children():
		if child.has_method("play"):
			child.call("play")


func stop():
	for child in get_children():
		if child.has_method("stop"):
			child.call("stop")
