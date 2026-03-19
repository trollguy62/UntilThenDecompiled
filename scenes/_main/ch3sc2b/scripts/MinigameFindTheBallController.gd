extends Node

const Command = preload("res://data/Command.gd")

@onready var minigame = get_parent()

var _command_handler = _run_command


func _ready():
	minigame.cup_chosen.connect(_on_cup_chosen)
	minigame.reveal_cups_opened.connect(_on_reveal_cups_opened)
	minigame.cup_swaps_finished.connect(_on_cup_swaps_finished)


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _on_cup_chosen(idx):
	Story.emit("ftb.cup_chosen", idx)


func _on_reveal_cups_opened(is_correct):
	Story.emit("ftb.reveal_cups_opened", is_correct)


func _on_cup_swaps_finished():
	var signal_name = "cup_swaps_finished"
	Story.emit("ftb.%s" % signal_name)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"ftb.set_swap_speed":
			var speed = params[0]
			minigame.cup_swap_speed = speed

		"ftb.set_continuous_swap_interval":
			var interval = params[0]
			minigame.cup_continuous_swap_interval = interval

		"ftb.set_impossible_game":
			minigame.impossible_game = bool(params[0])

		"ftb.prepare_for_swapping":
			if minigame._state == minigame.States.IDLE:
				minigame._state = minigame.States.ONGOING_IDLE
				await minigame._reveal_initial()

		"ftb.swap_once":
			if minigame._state == minigame.States.ONGOING_IDLE:
				minigame._swap()

		"ftb.start_swap_continuous":
			if minigame._state == minigame.States.ONGOING_IDLE:
				minigame._shuffle()
				minigame._state = minigame.States.ONGOING_SWAPPING

		"ftb.stop_swap_continuous":
			if (
				minigame._state == minigame.States.ONGOING_IDLE
				or minigame._state == minigame.States.ONGOING_SWAPPING
			):
				await minigame._stop_shuffle_swap()

		"ftb.finish_swapping":
			if minigame._state == minigame.States.ONGOING_IDLE:
				minigame._state = minigame.States.IDLE

		"ftb.request_player_choice":
			if minigame._state == minigame.States.IDLE:
				minigame._state = minigame.States.CHOOSING
				minigame._allow_cup_selection(true)

		"ftb.reveal":
			if minigame._state == minigame.States.PENDING_REVEAL:
				minigame._state = minigame.States.REVEALING
				minigame._reveal_cups()

		"ftb.is_correct_cup_chosen":
			if minigame._state == minigame.States.PENDING_REVEAL:
				return minigame.ball_cup == minigame.cups[minigame._selected_cup_idx]
			return false

		"ftb.set_illuminated":
			minigame.illuminated = params[0]
		_:
			return Constants.CMD_RETURN_NONE

	return null
