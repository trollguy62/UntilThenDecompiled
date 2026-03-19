extends Node2D

signal aimed
signal attack_started
signal attack_failed
signal attack_worked
signal turn_finished
signal won

@export var player_name: String

@onready var stick = $Stick
@onready var chibi = $Chibi
@onready var score_label = $Score

var score = 0
var max_score = 4
var eligible_for_perfect_ach = true


func _ready():
	add_to_group("players")
	chibi.animation = "idle"
	chibi.active = false


func _process(_delta):
	score_label.text = "%d / %d" % [score, max_score]
	stick.atk_strength_ind_speed = lerp(4, 6, float(score) / max_score)


func start_turn():
	stick.start_turn()

	await stick.turn_started
	chibi.active = true

	await stick.aim_position_started
	chibi.animation = "aiming"

	await stick.aim_position_finished
	emit_signal_to_player("aimed")

	await stick.aim_strength_finished
	emit_signal_to_player("aimed")

	await stick.attack_started
	emit_signal_to_player("attack_started")
	chibi.animation = "waiting"

	var fishball_count: int = await stick.attack_finished
	score += fishball_count

	if fishball_count > 0:
		emit_signal_to_player("attack_worked")
	else:
		emit_signal_to_player("attack_failed")
		eligible_for_perfect_ach = false

	await stick.turn_finished
	emit_signal_to_player("turn_finished")

	if is_winner():
		emit_signal_to_player("won")
		if eligible_for_perfect_ach and player_name == "Mark":
			Game.dist_platform.unlock_achievement("ACH_FISHBALL_PERFECT")


func emit_signal_to_player(s: String):
	emit_signal(s)
	get_tree().call_group("players", "_on_player_%s" % s, self)


func is_winner() -> bool:
	return score >= max_score


func _on_player_attack_failed(player):
	chibi.animation = "angry" if player == self else "happy"
	if player == self:
		chibi.shake()


func _on_player_attack_worked(player):
	chibi.animation = "happy" if player == self else "angry"
	if player != self:
		chibi.shake()


func _on_player_turn_finished(player):
	chibi.animation = "idle"
	chibi.active = false


func _on_player_won(player):
	chibi.active = player == self
	chibi.animation = "happy" if player == self else "angry"
