extends Node2D

@export var button_group: ButtonGroup
@export var floor_shots: Array[String] = []

@export var led_screen_overlay_1f: Texture
@export var led_screen_overlay_2f: Texture
@export var led_screen_overlay_3f: Texture
@export var led_screen_overlay_4f: Texture
@export var led_screen_overlay_broken: Texture

@onready var scene_manager = Service.of("SceneManager") as SceneManager
@onready var buttons = [$Button1, $Button2, $Button3, $Button4]
@onready var led_screen_overlay = $LedScreen/Overlay

@onready var state := Utils.get_state_container_of("scene") as StateContainer

@onready var led_screen_overlay_floors = [
	led_screen_overlay_1f, led_screen_overlay_2f, led_screen_overlay_3f, led_screen_overlay_4f
]

var _current_floor := 0
var _target_floor := -1
var _broken := false


func _ready():
	clear_state()

	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))


func clear_state():
	_target_floor = -1
	_set_buttons_selectable(false)

	var pressed_btn = button_group.get_pressed_button()
	if pressed_btn != null:
		pressed_btn.pressed = false


func query_floor():
	clear_state()
	_set_buttons_selectable(true)
	buttons[_current_floor].mouse_filter = Control.MOUSE_FILTER_IGNORE

	while _target_floor < 0:
		await Utils.wait(0)

	_set_buttons_selectable(false)
	Story.emit("_elevator_floor_selected")


func goto_target_floor():
	var shot = floor_shots[_target_floor]
	scene_manager.change_shot(shot)
	_current_floor = _target_floor


func _on_button_pressed(i: int):
	_target_floor = i
	$SfxButtonPress.play()
	state.dict.set_value("elevator_target_floor", _target_floor)


func _set_buttons_selectable(selectable: bool):
	for btn in buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_STOP if selectable else Control.MOUSE_FILTER_IGNORE


func _update_led_screen_overlay():
	var texture = led_screen_overlay_broken

	if not _broken:
		texture = led_screen_overlay_floors[_current_floor]

	led_screen_overlay.texture = texture


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params := cmd.params

	match cmd.name:
		"elevator_query_floor":
			query_floor()
			_update_led_screen_overlay()
		"elevator_to_target_floor":
			goto_target_floor()
		"elevator_set_current_floor":
			_current_floor = int(params[0]) - 1
			_update_led_screen_overlay()
		"elevator_set_broken":
			_broken = bool(params[0])
			_update_led_screen_overlay()
		_:
			return Constants.CMD_RETURN_NONE

	return null
