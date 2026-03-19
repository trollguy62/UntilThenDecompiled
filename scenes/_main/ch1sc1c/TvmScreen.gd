extends Control

const COIN_SLOT_ALIAS = "TVM_CoinSlot"

const SpeechBubbleView = preload("res://components/SpeechBubble/SpeechBubble.tscn")

signal order_completed

@export var scene_id = "1.1c"
@export var out_of_order_station_indices: Array[int]

@onready var scene_state = Service.of("SceneState")

@onready var tvm = $Container/TVM
@onready var focus = $Focus
@onready var tween = Threen.new()

var coin_sequence := []
var wrong_station_count = 0

func _ready():
	add_child(tween)
	hide_screen()
	tvm.out_of_order_station_indices = out_of_order_station_indices

	if OS.get_name() == "Prospero":
		var Prospero_Cursor = get_node("Prospero_Cursor")
		var vp = get_viewport()
		Prospero_Cursor.visible = true
		vp.warp_mouse(vp.get_visible_rect().size / 2)
		Prospero_Cursor.position = Vector2(vp.size) / 2 + Prospero_Cursor.texture.get_size() / 2



func show_screen():
	visible = true
	tvm.visible = true
	focus.push()

	tvm.forbidden_station_selected.connect(_on_forbidden_station_selected)
	tvm.out_of_order_station_selected.connect(_on_out_of_order_station_selected)
	tvm.payment_entered.connect(_on_payment_entered)
	tvm.ticket_processed.connect(_on_ticket_processed)
	tvm.order_completed.connect(_on_order_completed)


func hide_screen():
	visible = false
	tvm.visible = false
	focus.pop()


func _process(delta):
	if _is_controller_enabled():
		_get_controller_input(delta)


func _on_forbidden_station_selected():
	var short_id = scene_id + ".wrong_station"
	await Story.start_short(short_id)
	wrong_station_count += 1

	if wrong_station_count == 10:
		Game.dist_platform.unlock_achievement("ACH_TVM_WRONG_STATION_10")



func _on_out_of_order_station_selected():
	var short_id = scene_id + ".out_of_order_station"
	await Story.start_short(short_id)


func _on_payment_entered():
	coin_sequence.clear()
	_insert_coin()


func _insert_coin():
	Story.start_short(scene_id + ".query_insert_coin")
	var amount = await Story.wait_for("coin_amount")
	await Utils.wait_frames(2)

	var complete = tvm.insert_money(amount)
	coin_sequence.append(amount)

	if complete and coin_sequence.size() == 15:
		Game.dist_platform.unlock_achievement("ACH_TVM_P1_COINS_ONLY")

	if not complete:
		await _react_to_coin_sequence()
		await Utils.wait(0.5)
		_insert_coin()



func _react_to_coin_sequence():
	var short_knot = ""

	if coin_sequence.count(1) == 3 and coin_sequence.back() == 1:
		short_knot = "tvm_coins_1_3"
	elif coin_sequence.size() == 10:
		short_knot = "tvm_coins_n_10"

	if short_knot != "":
		var short_id = "%s.%s" % [scene_id, short_knot]
		await Story.start_short(short_id)

	await get_tree().process_frame


func _on_ticket_processed(change: int):
	if change % 5 != 0:
		Story.start_short(scene_id + ".tvm_irregular_change")


func _on_order_completed():
	scene_state.dict.set_value("has_ticket", true)
	order_completed.emit()


func _is_controller_enabled():
	return not Input.get_connected_joypads().is_empty() and visible


func _get_controller_input(delta):
	var input_v = _get_input()

	if input_v.length() < 0.05:
		return

	var sensitivity = 600.0
	var vp = get_viewport()
	var to_mouse_pos: Vector2 = vp.get_mouse_position() + input_v * sensitivity * delta

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


func _input(event):
	if event.is_action("c_interact") and _is_controller_enabled():
		get_viewport().set_input_as_handled()
		_emulate_mouse(event.pressed)
