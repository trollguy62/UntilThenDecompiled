@tool
extends Node3D
class_name GiBakeVisibilityController

@export var apply_to_parent := false
@export var show_during_bake := false

var _baking := false
var _was_visible := false


func get_custom_class():
	return "GiBakeVisibilityController"


func _process(delta):
	if _baking:
		_process_baking()


func _process_baking():
	_set_visible(show_during_bake)


func pre_bake():
	_baking = true
	_was_visible = _get_visible()
	_process_baking()


func post_bake():
	_baking = false
	_set_visible(_was_visible)


func _set_visible(visible: bool):
	self.visible = visible
	if apply_to_parent:
		get_parent().visible = visible


func _get_visible() -> bool:
	return get_parent().visible if apply_to_parent else self.visible
