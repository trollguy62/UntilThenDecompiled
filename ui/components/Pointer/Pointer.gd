extends Control

var was_visible = false
var is_prospero = false

func _ready():
	was_visible = false
	is_prospero = OS.get_name() == "Prospero"
	if is_prospero:
		var Prospero_Cursor = get_node("Prospero_Cursor")
		var ancestor = get_parent().get_parent()
		if ancestor:
			ancestor = ancestor.get_parent()
			if ancestor and ancestor.name == "PaintingMinigame":
				Prospero_Cursor.visible = false
				return
		Prospero_Cursor.visible = true
		Prospero_Cursor.scale = Vector2(1, 1) / get_parent().scale

func _recenter():
	if is_prospero:
		var parent = get_parent()
		var Prospero_Cursor = get_node("Prospero_Cursor")
		var vp = get_viewport()
		var vp_visible_rect = vp.get_visible_rect()
		vp.warp_mouse(vp_visible_rect.size / 2)
		var parent_pos = Vector2(0, 0)
		if "position" in parent:
			parent_pos = parent.position
		Prospero_Cursor.position = (vp_visible_rect.size / 2 - parent_pos + Prospero_Cursor.texture.get_size() / 2) / parent.scale
		if parent.name == "MinigameLabBoard":
			Prospero_Cursor.position += parent.get_node("Camera").position # Add camera displacement to cursor position
		elif parent.name == "NotesBox":
			if parent.get_parent().get_parent().entrypoint == "lo.5.2.FreeRoam":
				Prospero_Cursor.position -= vp_visible_rect.size / 2

func _process(delta):
	var is_visible = is_visible_in_tree()
	var enabled = _is_controller_enabled() and is_visible
	if enabled:
		if is_prospero and is_visible and not was_visible:
			_recenter()
		_get_controller_input(delta)
	was_visible = is_visible

func _is_controller_enabled():
	return not Input.get_connected_joypads().is_empty()

func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("c_move_right") - Input.get_action_strength("c_move_left"),
		Input.get_action_strength("c_move_down") - Input.get_action_strength("c_move_up")
	)

func _get_controller_input(delta):
	var input_v = _get_input()

	if input_v.length() < 0.01:
		return

	var sensitivity = 600.0
	var vp = get_viewport()
	var to_mouse_pos: Vector2 = vp.get_mouse_position() + input_v * sensitivity * delta

	var vp_visible_rect = vp.get_visible_rect()
	to_mouse_pos.x = clamp(to_mouse_pos.x, 0, vp_visible_rect.size.x)
	to_mouse_pos.y = clamp(to_mouse_pos.y, 0, vp_visible_rect.size.y)

	if is_prospero:
		var parent = get_parent()
		var Prospero_Cursor = get_node("Prospero_Cursor")
		var parent_pos = Vector2(0, 0)
		if "position" in parent:
			parent_pos = parent.position
		if Prospero_Cursor.texture.get_size() == Vector2(18, 29):
			Prospero_Cursor.position = (to_mouse_pos - parent_pos + Prospero_Cursor.texture.get_size() / 2) / parent.scale
		else:
			Prospero_Cursor.position = (to_mouse_pos - parent_pos) / parent.scale
		if parent.name == "MinigameLabBoard":
			Prospero_Cursor.position += parent.get_node("Camera").position # Add camera displacement to cursor position
		elif parent.name == "Metronome":
			var box_container = parent.get_node("HBoxContainer")
			var start_button = box_container.get_node("StartButton")
			if (not start_button._mouse_entered) and to_mouse_pos.x >= 16 + box_container.position.x and \
				to_mouse_pos.x < 16 + box_container.position.x + start_button.size.x and \
				to_mouse_pos.y >= box_container.position.y and \
				to_mouse_pos.y < box_container.position.y + start_button.size.y:
				start_button._on_hovered()
			elif (start_button._mouse_entered) and (to_mouse_pos.x < 16 + box_container.position.x or \
				to_mouse_pos.x >= 16 + box_container.position.x + start_button.size.x or \
				to_mouse_pos.y < box_container.position.y or \
				to_mouse_pos.y >= box_container.position.y + start_button.size.y):
				start_button._on_unhovered()
		elif parent.name == "NotesBox":
			if parent.get_parent().get_parent().entrypoint == "lo.5.2.FreeRoam":
				Prospero_Cursor.position -= vp_visible_rect.size / 2
				
	vp.warp_mouse(to_mouse_pos)

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
		event.pressed = false
		Input.parse_input_event(event)

func _input(event):
	if event.is_action("c_interact") and _is_controller_enabled() and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		if is_prospero:
			var parent = get_parent()
			if parent.name == "Metronome":
				var start_button = parent.get_node("HBoxContainer").get_node("StartButton")
				if start_button._mouse_entered and not event.pressed:
					start_button._on_pressed()
					return
		_emulate_mouse(event.pressed)
