extends Node2D

signal disappear_requested
signal pin_removed
signal all_pins_removed

@onready var focus = $Focus
@onready var pins = $ViewportContainer/Viewport/Pins
@onready var ptr_vis_timer = $PointerVisibilityTimer

var pins_removed: int = 0 : get = _get_pins_removed
var _cancelable := false
var _controller_enabled = false


func _enter_tree():
	modulate = Color.TRANSPARENT


func _ready():
	for pin in pins.get_children():
		pin.removed.connect(_on_pin_removed)
	
	if OS.get_name() == "Prospero":
		var Prospero_Cursor = get_node("Prospero_Cursor")
		var vp = get_viewport()
		Prospero_Cursor.visible = true
		vp.warp_mouse(vp.get_visible_rect().size / 2)
		Prospero_Cursor.position = Vector2(vp.size) / 2 + Prospero_Cursor.texture.get_size() / 2
	


func _process(delta):
	if Input.is_action_just_pressed("k_interact") or Input.is_action_just_pressed("c_cancel"):
		if _cancelable and focus.active:
			disappear_requested.emit()

	if _controller_enabled:
		_get_controller_input(delta)


func _on_pin_removed():
	pins_removed += 1
	pin_removed.emit()
	if pins_removed == pins.get_child_count():
		all_pins_removed.emit()


func _get_pins_removed():
	return pins_removed


func appear():
	focus.push()
	modulate = Color.WHITE
	await get_tree().create_timer(2).timeout
	_cancelable = true
	_controller_enabled = true


func disappear():
	if _cancelable:
		focus.pop()
		modulate = Color.TRANSPARENT
		_cancelable = false
		_controller_enabled = false


func _get_controller_input(delta):
	var input_v = _get_input()

	if input_v.length() < 0.05:
		return

	var sensitivity = 600.0

	var to_mouse_pos: Vector2 = get_viewport().get_mouse_position() + input_v * sensitivity * delta
	var vp = get_viewport()
	var vp_visible_rect = vp.get_visible_rect()
	to_mouse_pos.x = clamp(to_mouse_pos.x, 0, vp_visible_rect.size.x)
	to_mouse_pos.y = clamp(to_mouse_pos.y, 0, vp_visible_rect.size.y)

	vp.warp_mouse(to_mouse_pos)
	if OS.get_name() == "Prospero":
		var Prospero_Cursor = get_node("Prospero_Cursor")
		Prospero_Cursor.position = to_mouse_pos + Prospero_Cursor.texture.get_size() / 2


func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("c_move_right") - Input.get_action_strength("c_move_left"),
		Input.get_action_strength("c_move_down") - Input.get_action_strength("c_move_up")
	)


func _emulate_mouse(pressed):
	var event = InputEventMouseButton.new()
	event.set_button_index(MOUSE_BUTTON_LEFT)
	event.position = get_viewport().get_mouse_position()
	event.position *= (
		get_viewport().size.y
		/ float(ProjectSettings.get_setting_with_override("display/window/size/viewport_height"))
	)
	if pressed:
		event.pressed = pressed
		Input.parse_input_event(event)
	else:
		#emulates click
		event.pressed = true
		Input.parse_input_event(event)
		event.pressed = false
		Input.parse_input_event(event)


func _unhandled_input(event):
	if event.is_action("c_interact") and _controller_enabled:
		get_viewport().set_input_as_handled()
		_emulate_mouse(event.pressed)
