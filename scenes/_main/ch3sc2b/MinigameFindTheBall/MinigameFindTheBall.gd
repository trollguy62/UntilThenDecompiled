extends Node2D

signal cups_swapped
signal cup_swaps_finished
signal cup_chosen(idx)
signal reveal_cups_opened(correct)

enum States {
	IDLE,
	ONGOING_INITIAL,
	ONGOING_IDLE,
	ONGOING_SWAPPING,
	CHOOSING,
	PENDING_REVEAL,
	REVEALING
}

@export_range( 0, 2) var starting_ball_position = 1
@export var cup_horizontal_distance := 100.0
@export var cup_swap_speed := 0.5
@export var cup_swap_y_trans_peak := 1.0
@export var cup_focused_modulate_color := Color.RED
@export var cup_open_close_duration := 0.5
@export var cup_initial_show_delay_duration := 1.0
@export var cup_reveal_delay_duration := 1.0
@export var cup_continuous_swap_interval := 0.5
@export var impossible_game := false
@export var illuminated = false : set = set_illuminated

@onready var cups = [$Node2D/PaperCupA, $Node2D/PaperCupB, $Node2D/PaperCupC]
@onready var controller_buttons = [$Anchor/HBoxContainer/InputHint1, $Anchor/HBoxContainer/InputHint2, $Anchor/HBoxContainer/InputHint3]
@onready var ball_cup = cups[starting_ball_position]
@onready var ball = $Ball
@onready var focus = $Focus
@onready var light_shaft = $LightShaft
@onready var tween = Threen.new()

@onready var sfx_correct_choice = $SFX/CorrectChoice
@onready var sfx_wrong_choice = $SFX/WrongChoice
@onready var sfx_cup_swap = $SFX/CupSwap
@onready var button_anchor = $Anchor

var _stop_shuffle: bool
var _state = States.IDLE
var _selected_cup_idx := -1
var _highlighted_cup_idx = -1#: set = _set_highlighted_cup_idx
var _allow_selection = false:
	set(v):
		_allow_selection = v
		if _allow_selection:
			button_anchor.fade_in()
		else:
			button_anchor.fade_out()

var _cup_input_mapping: Dictionary = {}

func _ready():
	add_child(tween)
	for cup in cups:
		cup.reveal_finish.connect(_on_reveal_finish)
		cup.select.connect(_on_selected)

	ball.visible = false

	light_shaft.modulate = Color.TRANSPARENT

func _process(delta):
	for cup in cups:
		cup.horizontal_distance = cup_horizontal_distance
		cup.swap_speed = cup_swap_speed
		cup.focused_color = cup_focused_modulate_color
		cup.open_close_duration = cup_open_close_duration
		cup.initial_show_delay_duration = cup_initial_show_delay_duration
		cup.swap_y_trans_peak = cup_swap_y_trans_peak


func set_illuminated(value: bool):
	illuminated = value

	if is_inside_tree():
		var c0 = light_shaft.modulate
		var c1 = Color.WHITE if illuminated else Color.TRANSPARENT

		tween.interpolate_property(light_shaft, "modulate", c0, c1, 1.0)
		tween.start()

		for cup in cups:
			cup.illuminate(illuminated, cup == ball_cup)


# continuous swap
func _shuffle():
	_allow_cup_selection(false)

	while true:
		await _swap()
		await Utils.wait(cup_continuous_swap_interval)

		if _stop_shuffle:
			_stop_shuffle = false
			await get_tree().process_frame
			break

	_state = States.ONGOING_IDLE
	_emit_signal_with_story_emit("cup_swaps_finished")


# stop continouous swap
func _stop_shuffle_swap():
	_stop_shuffle = true
	await cup_swaps_finished


# swap once
func _swap():
	var call
	match randi() % 3:
		0:
			await _swap_cups(0, 1)
		1:
			await _swap_cups(1, 2)
		2:
			await _swap_cups(0, 2)


	cups_swapped.emit()


func _swap_cups(i: int, j: int):
	sfx_cup_swap.play()

	cups[i].move_by(j - i)
	await cups[j].move_by(i - j)


	var temp = cups[i]
	cups[i] = cups[j]
	cups[j] = temp


func _reveal_initial():
	if _state != States.ONGOING_IDLE:
		return

	var starting_cup = cups[starting_ball_position]
	ball.global_position = starting_cup.global_position
	ball.visible = true
	await starting_cup.reveal(true)


func _reveal_cups():
	var cup = cups[_selected_cup_idx]

	if impossible_game:
		var new_idx = (_selected_cup_idx + 1) % 3
		ball_cup = cups[new_idx]

	var is_correct = ball_cup == cup

	if is_correct:
		_reveal_ball()
		sfx_correct_choice.play()
		await Utils.wait(cup.open_close_duration)
	else:
		cup.open()
		await Utils.wait(cup.open_close_duration)
		sfx_wrong_choice.play()
		_reveal_ball()
		await Utils.wait(cup_reveal_delay_duration)
		cup.close()

	_emit_signal_reveal_cups_opened_with_story_emit(is_correct)

	_state = States.IDLE


# raises the cup containing the ball
func _reveal_ball():
	for i in range(cups.size()):
		if cups[i] == ball_cup:
			ball.global_position = cups[i].global_position
			ball.show()
			ball_cup = cups[i]
			cups[i].reveal(true)


func _on_reveal_finish():
	ball.hide()


func _allow_cup_selection(value):
	for cup in cups:
		cup.collider.set_deferred("disabled", not value)
	_allow_selection = value


func _on_selected(cup):
	if not _allow_selection:
		return
	_allow_cup_selection(false)
	_state = States.PENDING_REVEAL
	_selected_cup_idx = cups.find(cup)
	_emit_signal_cup_chosen_with_story_emit(_selected_cup_idx)


func _emit_signal_with_story_emit(signal_name):
	emit_signal(signal_name)


func _emit_signal_reveal_cups_opened_with_story_emit(is_correct):
	emit_signal("reveal_cups_opened", is_correct)


func _emit_signal_cup_chosen_with_story_emit(idx):
	emit_signal("cup_chosen", idx)


func _reset_cups():
	for cup in cups:
		cup.tween.emit_signal("tween_all_completed")
		cup.reset_position()

func _unhandled_input(event):
	if not is_visible_in_tree():
		return

	if event.is_action_pressed("choice_1"):
		_highlighted_cup_idx = 0
		_on_selected(cups[_highlighted_cup_idx])

	if event.is_action_pressed("choice_2"):
		_highlighted_cup_idx = 1
		_on_selected(cups[_highlighted_cup_idx])

	if event.is_action_pressed("choice_3"):
		_highlighted_cup_idx = 2
		_on_selected(cups[_highlighted_cup_idx])
