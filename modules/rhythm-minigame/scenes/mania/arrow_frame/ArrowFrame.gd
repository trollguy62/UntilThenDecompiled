extends Node2D

signal input_triggered(column, state)

const WHITE_FILL = preload("res://modules/rhythm-minigame/assets/mania/shaders/FloodFillWhite.material")
const RhythmGameConstants = preload("res://modules/rhythm-minigame/utils/RhythmGameConstants.gd")


@export var arrow_textures: Dictionary = {"filled": [], "unfilled": []}

@export var use_controller_textures: bool = false:
	set(v):
		use_controller_textures = v
		if use_controller_textures:
			for i in arrows.size():
#				while (not controller_textures[i]):
#					await get_tree().process_frame
				arrows[i].texture = controller_textures[i]
				arrows[i].texture_unpressed = controller_textures[i]
				arrows[i].use_material_for_pressed = true
		else:
			for i in arrows.size():
				arrows[i].texture = arrow_textures["unfilled"][i]
				arrows[i].texture_pressed = arrow_textures["filled"][i]
				arrows[i].texture_unpressed = arrow_textures["unfilled"][i]
				arrows[i].use_material_for_pressed = false

@onready var arrows: Array = $Arrows.get_children()

var is_enabled = false:
	set(v):
		set_process_unhandled_input(v)
		is_enabled = v
var controller_textures: Array = [null, null, null, null]

func _input(event):
	if !event.is_echo() and is_visible_in_tree():
		if event.is_action("rhythm_left") or (event is InputEventKey and event.keycode == KEY_LEFT):
			_trigger(RhythmGameConstants.COLUMN.LEFT, event.is_pressed())

		if event.is_action("rhythm_down") or (event is InputEventKey and event.keycode == KEY_DOWN):
			_trigger(RhythmGameConstants.COLUMN.DOWN, event.is_pressed())

		if event.is_action("rhythm_up") or (event is InputEventKey and event.keycode == KEY_UP):
			_trigger(RhythmGameConstants.COLUMN.UP, event.is_pressed())

		if event.is_action("rhythm_right") or (event is InputEventKey and event.keycode == KEY_RIGHT):
			_trigger(RhythmGameConstants.COLUMN.RIGHT, event.is_pressed())

func _trigger(column: int, pressed: bool):
	arrows[column].update_state(pressed)
	input_triggered.emit(column, pressed)


func apply_hit_result(hit_result, column):
	arrows[column].apply_hit_result(hit_result)
