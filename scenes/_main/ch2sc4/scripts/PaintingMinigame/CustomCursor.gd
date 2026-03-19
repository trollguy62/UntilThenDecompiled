extends Node2D

@onready var parent = get_parent()

var _old_parent_visible = false


func _ready():
	_old_parent_visible = parent.is_visible_in_tree()
	_on_parent_visibility_changed(_old_parent_visible)


func _process(delta):
	var is_parent_visible = parent.is_visible_in_tree()
	if is_parent_visible != _old_parent_visible:
		_old_parent_visible = is_parent_visible
		_on_parent_visibility_changed(is_parent_visible)

	global_position = get_global_mouse_position()


func _on_parent_visibility_changed(visible: bool):
	var hide_cursor = Game.config.hide_cursor
	self.visible = visible and not hide_cursor

	Input.set_mouse_mode(
		Input.MOUSE_MODE_HIDDEN if (visible or hide_cursor) else Input.MOUSE_MODE_VISIBLE
	)
