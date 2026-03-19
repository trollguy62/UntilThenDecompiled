extends "InputController.gd"

const Player = preload("Player.gd")
const Fishball = preload("Fishball.gd")

const STATE_IDLE = 0
const STATE_AIM_POSITION = 1
const STATE_AIM_STRENGTH = 2

@export var opponent_path : NodePath

@onready var stick = get_parent()
@onready var area = $Area2D

@onready var player = stick.get_parent() as Player
@onready var opponent = get_node(opponent_path) as Player

var intelligence = 0.5
var _press = false
var _state = STATE_IDLE


func _ready():
	stick.aim_position_started.connect(_on_aim_position_started)
	stick.aim_strength_started.connect(_on_aim_strength_started)


func _process(_delta):
	match _state:
		STATE_AIM_POSITION:
			for oa in area.get_overlapping_areas():
				if Fishball.get_fishball_of(oa):
					_press = true
					_state = STATE_IDLE
		STATE_AIM_STRENGTH:
			var can_aim = randf() <= intelligence
			var atks = stick.atk_strength
			var min_atks = 0.65 if can_aim else 0.5 * intelligence
			var max_atks = 1 if can_aim else 0.65
			if min_atks <= atks and atks <= max_atks:
				_press = true
				_state = STATE_IDLE


func is_just_pressed() -> bool:
	if _press:
		_press = false
		return true
	return false


func _update_intelligence():
	if player.score == player.max_score - 1 or player.score > opponent.score:
		intelligence = randf_range(0.7, 0.98)
	elif player.score < opponent.score:
		intelligence = randf_range(0.8, 0.92)
	else:
		intelligence = randf_range(0.6, 0.95)


func _on_aim_position_started():
	await Utils.wait(randf_range(1, 3))
	_update_intelligence()
	_state = STATE_AIM_POSITION


func _on_aim_strength_started():
	await Utils.wait(randf_range(0.5, 2))
	_state = STATE_AIM_STRENGTH
