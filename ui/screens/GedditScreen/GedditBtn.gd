extends TextureButton

@export var hover_modulate: Color = Color(Color.GREEN, 0.5)
var _base_modulate: Color = modulate

func _process(_delta):
	modulate = hover_modulate if _is_focused() else _base_modulate

func _is_focused():
	return is_hovered() or get_viewport().gui_get_focus_owner() == self
