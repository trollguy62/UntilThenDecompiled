extends Control

signal bg_color_changed()
signal dismissed(return_value)

@export var focus_on_enter: Control

var bg_color: Color = Color(0, 0, 0, 0.5):
	set(value):
		bg_color = value
		bg_color_changed.emit()
	get:
		return bg_color

var cancelable: bool = true

var _modal_handler
var _return_value


func _ready():
	self.mouse_filter = MOUSE_FILTER_IGNORE


func _reveal(handler):
	_modal_handler = handler


func _dismiss():
	_modal_handler = null
	dismissed.emit(_return_value)


func dismiss():
	if _modal_handler:
		_modal_handler.dismiss()

func _on_navigator_screen_pushed():
	pass


func set_focused():
	if focus_on_enter:
		focus_on_enter.grab_focus()
