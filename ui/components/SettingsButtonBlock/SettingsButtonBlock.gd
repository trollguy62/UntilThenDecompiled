extends HBoxContainer

const Keybind = preload("res://data/Keybind.gd")

signal keybind_updated(new_keybind)

enum {
	STATE_STANDBY,
	STATE_REMAPPING_KB,
	STATE_REMAPPING_CONTROLLER
}

@onready var button = $Button
@onready var label = $Label
@onready var c_button = $CButton
@onready var c_button_texture = $CButton/TextureRect
@export var keybind: Keybind:
	set(v):
		if not is_node_ready():
			await ready

		keybind = v
		_update()

var _state = STATE_STANDBY

func _ready():
	# Disable keyboard controls on PS5
	if OS.get_name() == "Prospero":
		button.disabled = true
		button.visible = false
	else:
		button.toggled.connect(_on_button_toggled.bind(button))
		
	c_button.toggled.connect(_on_button_toggled.bind(c_button))
	set_process_input(false)

func _update():
	label.set_deferred("text", keybind.name)

	var key_action = keybind.action

	# Disable keyboard controls on PS5
	if OS.get_name() != "Prospero":
		if not InputMap.action_get_events(key_action).is_empty():
			var kb_key = keybind.key
			var text = kb_key.as_text() if kb_key != null else "N/A"
			button.set_deferred("text", text)

	c_button_texture.set_deferred("path", key_action)

func _on_button_toggled(is_button_pressed, which):
	set_process_input(is_button_pressed)
	if is_button_pressed:
		release_focus()
		if which == button:
			button.text = "?"
			_state = STATE_REMAPPING_KB
		elif which == c_button:
			c_button_texture.texture = null
			_state = STATE_REMAPPING_CONTROLLER

	else:
		which.grab_focus()

func _input(event):
	if not event.is_pressed():
		return

	if event is InputEventKey and _state == STATE_REMAPPING_KB:
		_remap_action_to(event)
		_reset_state()

	if (event is InputEventJoypadButton and event.button_index != JOY_BUTTON_START) or event is InputEventJoypadMotion and _state == STATE_REMAPPING_CONTROLLER:
		_remap_action_to(event)
		_reset_state()

	get_viewport().set_input_as_handled()

func _reset_state():
	button.button_pressed = false
	c_button.button_pressed = false
	_state = STATE_STANDBY

func _remap_action_to(new_bind):
	var old_bind

	if new_bind is InputEventKey:
		old_bind = keybind.key
		keybind.key = new_bind
	elif new_bind is InputEventJoypadButton or new_bind is InputEventJoypadMotion:
		old_bind = keybind.c_key
		keybind.c_key = new_bind

	InputMap.action_erase_event(keybind.action, old_bind)
	InputMap.action_add_event(keybind.action, new_bind)

	_update()
	keybind_updated.emit(keybind)

func reset():
	_update()
