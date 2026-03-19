extends VBoxContainer

@onready var _button_container := $ButtonContainer
@onready var _content_container := $ScrollContainer/Content

@onready var _buttons: Array = _button_container.get_children() \
		.filter(func(n): return n is Button)

var _has_exited_container: bool = true
var _last_pressed_button_idx := -1


func _ready():
	for i in range(_buttons.size()):
		var btn = _buttons[i]

		# Hide settings not needed for PS5
		if OS.get_name() == "Prospero":
			if btn.text == "SETTINGS_CATEG_VIDEO" or btn.text == "SETTINGS_CATEG_GRAPHICS":
				btn.disabled = true
				btn.visible = false
				continue

		btn.pressed.connect(_on_button_pressed.bind(i))
		btn.focus_entered.connect(_on_focus_entered.bind(btn))

		if btn.button_pressed:
			_on_button_pressed(i)

	#FIXME: feels slightly hacky
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	_on_button_pressed(0)


func _on_button_pressed(idx: int):
	if _last_pressed_button_idx != idx:
		_last_pressed_button_idx = idx
		_content_container.show_content(idx)


func _on_focus_changed(control):
	_has_exited_container = not control in _button_container.get_children()


func _on_focus_entered(button):
	if _has_exited_container:
		button.grab_focus()
		_has_exited_container = false
