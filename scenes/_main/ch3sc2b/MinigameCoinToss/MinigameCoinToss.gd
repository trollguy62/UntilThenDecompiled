extends Node2D

signal tossed(points)
signal aim_repositioned

const CoinScene = preload("res://scenes/_main/ch3sc2b/MinigameCoinToss/prefabs/Coin.tscn")
const Coin = preload("res://scenes/_main/ch3sc2b/MinigameCoinToss/scripts/Coin.gd")
const TextPopup = preload("res://scenes/_main/ch3sc2a/scripts/TextPopup/TextPopup.tscn")

enum States { IDLE, AIMING_POSITION, AIMING_STRENGTH, POST_AIM }

@onready var board = $BG/Board
@onready var crosshair = $Crosshair
@onready var constraint = $BG/Constraint
@onready var meter = $Meter
@onready var focus = $Focus
@onready var ai = $AIController

@onready var sfx_coins_from_pocket = $SFX/CoinsFromPocket
@onready var sfx_coin_flip = $SFX/CoinFlip
@onready var sfx_coin_drop = $SFX/CoinDrop
@onready var sfx_set_position = $SFX/SetPosition

@export var aim_interval_rand_min := 0.5
@export var aim_interval_rand_max := 1.5
@export var aim_reposition_duration_rand_min := 0.5
@export var aim_reposition_duration_rand_max := 1.5
@export var crosshair_fade_duration := 1.0
@export var player_strength_meter_speed_factor := 1.0
@export var dart_fade_out_duration := 1.0
@export var joystick_aim_speed := 1000

var _agents = {}
var _active_agent_alias: String
var _state = States.IDLE
var _accuracy: float


func _ready():
	meter.reset_indicator_position()

	ai.board = board
	ai.crosshair = crosshair
	ai.meter = meter

	crosshair.fire.connect(_on_fire)
	ai.fire.connect(_toss_coin)
	ai.aim_reposition.connect(_on_aim_repositioned)


func _process(delta):
	crosshair.constraint = constraint
	crosshair.fade_duration = crosshair_fade_duration
	crosshair.joystick_aim_speed = joystick_aim_speed
	crosshair.focus = focus

	meter.indicator_speed = player_strength_meter_speed_factor

	ai.aim_interval_rand_min = aim_interval_rand_min
	ai.aim_interval_rand_max = aim_interval_rand_max
	ai.aim_reposition_duration_rand_min = aim_reposition_duration_rand_min
	ai.aim_reposition_duration_rand_max = aim_reposition_duration_rand_max


func _on_fire():
	if _state == States.AIMING_POSITION:
		_state = States.AIMING_STRENGTH
		meter.start()
		sfx_set_position.play()
		crosshair.target_lock = true
	elif _state == States.AIMING_STRENGTH:
		_state = States.POST_AIM
		_toss_coin()
		crosshair.target_lock = false


func _toss_coin():
	var angle = crosshair.get_random_angle()
	var distance = crosshair.get_distance(meter.strength)

	var coin = CoinScene.instantiate()
	coin.fade_out_duration = dart_fade_out_duration
	add_child(coin)

	var accuracy = Vector2(cos(angle), sin(angle)) * distance
	var coin_position = Vector2(
		crosshair.position.x + accuracy.x, crosshair.position.y + accuracy.y
	)
	coin.position = coin_position

	var points = _get_points_for(coin)

	if points > 0:
		_add_score(points)

	_popup_score(max(0, points), coin.global_position)
	_emit_tossed_signal_with_story_emit(points)

	meter.stop()
	crosshair.flash()
	sfx_coin_flip.play()
	sfx_coin_drop.play()
	crosshair.set_process(false)


func _get_points_for(coin: Coin) -> int:
	var points = -1

	for pos in coin.get_test_global_positions():
		var pts = board.get_score_at(pos)

		if points < 0:
			points = pts
		elif points != pts:
			return 0

	if points > 200:
		return -1
	else:
		return points


func _add_score(points):
	var state_container = _agents[_active_agent_alias][0]
	var score = state_container.dict.get_value("cointoss_score")
	score += points
	state_container.dict.set_value("cointoss_score", score)


func _popup_score(points: int, global_pos: Vector2):
	var text_popup = TextPopup.instantiate()
	text_popup.text = str(points)
	text_popup.global_position = global_pos
	add_child(text_popup)


func _emit_tossed_signal_with_story_emit(points):
	tossed.emit(points)


func _emit_signal_with_story_emit(signal_name):
	emit_signal(signal_name)


func _on_aim_repositioned():
	_emit_signal_with_story_emit("aim_repositioned")


func _add_agent(alias, is_player):
	var state_container = Utils.get_state_container_of(alias)

	if not state_container or _agents.has(alias):
		return

	state_container.dict.set_value("cointoss_score", 0)
	_agents[alias] = [state_container, is_player]


func _remove_agent(alias):
	if _active_agent_alias == alias:
		return

	_agents.erase(alias)
	_active_agent_alias = ""


func _set_current_agent(alias):
	if _active_agent_alias == alias:
		return

	var is_player = _agents[alias][1]
	crosshair.start(is_player)
	sfx_coins_from_pocket.play()
	_active_agent_alias = alias


func _remove_current_agent():
	if _state == States.POST_AIM:
		_state = States.IDLE
	else:
		return

	_active_agent_alias = ""
	crosshair.stop()


func _aim_position(aim_count, bullseye_tendency):
	if _state == States.POST_AIM:
		_state = States.AIMING_POSITION

	if _state != States.AIMING_POSITION:
		return

	if ai.is_aim_active:
		ai.stop_aim()

	ai.aim(aim_count, bullseye_tendency)
	await ai.aiming_finish


func _stop_aim():
	if _state != States.AIMING_POSITION:
		return

	ai.stop_aim()
	crosshair.stop()
	meter.stop()


func _start_aim_strength():
	if _state == States.AIMING_POSITION:
		_state = States.AIMING_STRENGTH
	else:
		return

	sfx_set_position.play()
	ai.aim_strength()


func _toss(accuracy):
	if _state == States.AIMING_STRENGTH:
		_state = States.POST_AIM
	else:
		return

	ai.toss(accuracy)


func _player_has_highest_score() -> bool:
	var max_score = 0
	var is_max_score_from_player = false

	for alias in _agents:
		var state_container: StateContainer = _agents[alias][0]
		var is_player: bool = _agents[alias][1]
		var score = state_container.dict.get_value("cointoss_score")

		if score > max_score:
			max_score = score
			is_max_score_from_player = is_player

	return is_max_score_from_player
