extends Node2D

signal pin_removed
signal all_pins_removed

const FADE_IN_DELAY = 0.5

@onready var focus = $Focus
@onready var board = $Board
@onready var pins = $Board/Pins
@onready var camera = $Camera

@onready var btn_scroll_up = $Control/Buttons/BtnScrollUp
@onready var btn_scroll_down = $Control/Buttons/BtnScrollDown
@onready var input_blocker = $Control/InputBlocker

@onready var fader = Service.of("SceneManager").fader

var board_y: float
var cam_y: float
var pins_removed: int = 0 

func _ready():
	board_y = board.texture.get_size().y * board.scale.y

	for pin in pins.get_children():
		pin.removed.connect(_on_pin_removed)

	btn_scroll_up.pressed.connect(_scroll_up)
	btn_scroll_down.pressed.connect(_scroll_down)

	_scroll_up()


func _process(delta):
	input_blocker.visible = not focus.active

	if not focus.active:
		return

	camera.position.y = lerp(camera.position.y, cam_y, 0.15)

func appear():
	await _toggle_appear(true)


func disappear():
	await _toggle_appear(false)


func _toggle_appear(show: bool):
	await fader.fade_out()

	if show:
		focus.push()
	else:
		focus.pop()

		_switch_page(true)
		camera.position = Vector2.ZERO

		await get_tree().process_frame

	visible = show
	if show:
		camera.make_current()

	await Utils.wait(FADE_IN_DELAY)
	await fader.fade_in()


func _scroll_up():
	_switch_page(true)


func _scroll_down():
	_switch_page(false)


func _switch_page(top: bool):
	btn_scroll_down.visible = top
	btn_scroll_up.visible = not top
	cam_y = 0 if top else board_y - get_viewport_rect().size.y
	if OS.get_name() == "Prospero":
		var Prospero_Cursor = get_node("Pointer").get_node("Prospero_Cursor")
		var to_mouse_pos = get_viewport().get_mouse_position()
		Prospero_Cursor.position = Vector2(0, cam_y) + (to_mouse_pos - position + Prospero_Cursor.texture.get_size() / 2) / scale


func _on_pin_removed():
	pins_removed += 1
	pin_removed.emit()
	if pins_removed == pins.get_child_count():
		all_pins_removed.emit()

func _input(event):
	if not focus.active:
		return
	#FIXME: hack
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_Y:
			return

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down") or event.is_action_pressed("c_rstick_down"):
		_scroll_down()

	elif event.is_action_pressed("move_up") or event.is_action_pressed("ui_up") or event.is_action_pressed("c_rstick_up"):
		_scroll_up()

	if event.is_action_pressed("interact") or event.is_action("c_cancel"):
		disappear()
