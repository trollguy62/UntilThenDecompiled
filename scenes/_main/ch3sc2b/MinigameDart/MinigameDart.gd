extends Node2D

signal thrown
signal aim_repositioned
signal shot_finished(score)

const dart_scene = preload("res://scenes/_main/ch3sc2b/MinigameDart/prefabs/Dart.tscn")
const Dart = preload("res://scenes/_main/ch3sc2b/MinigameDart/scripts/Dart.gd")
const TextPopup = preload("res://scenes/_main/ch3sc2a/scripts/TextPopup/TextPopup.tscn")

enum States { IDLE, AIMING_POSITION, AIMING_STRENGTH, POST_AIM }

@onready var board = $Board
@onready var crosshair = $Crosshair
@onready var meter = $Meter
@onready var ai = $AIController
@onready var focus = $Focus

@onready var sfx_dart_throw = $SFX/DartThrow
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
var _bullseye_tendency: float


func _ready():
	meter.reset_indicator_position()

	ai.board = board
	ai.crosshair = crosshair
	ai.meter = meter

	crosshair.fire.connect(_on_fire)
	ai.fire.connect(_spawn_dart)
	ai.aim_reposition.connect(_on_aim_repositioned)



func _process(delta):
	crosshair.board_pos = board.position
	crosshair.board_radius = board.texture.get_width() * 1.5
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
		_spawn_dart()


func _spawn_dart():
	var angle = crosshair.get_random_angle()
	var distance = crosshair.get_distance(meter.strength)

	var dart = dart_scene.instantiate()
	dart.fade_out_duration = dart_fade_out_duration
	add_child(dart)

	var accuracy = Vector2(cos(angle), sin(angle)) * distance
	var dart_position = Vector2(
		crosshair.position.x + accuracy.x, crosshair.position.y + accuracy.y
	)
	dart.position = dart_position

	var points = board.get_score_at(dart_position)

	if points > 0:
		_add_score(points)
		_popup_score(points, dart.global_position + Vector2.UP * 40)

	_emit_signal_with_story_emit("thrown")
	_emit_shot_finished_with_story_emit(points)

	sfx_dart_throw.play()
	meter.stop()
	crosshair.set_process(false)


func _add_score(points):
	var state_container = _agents[_active_agent_alias][0]
	var score = state_container.dict.get_value("darts_score")
	score += points
	state_container.dict.set_value("darts_score", score)


func _popup_score(points: int, global_pos: Vector2):
	var popup = TextPopup.instantiate()
	popup.text = str(points)
	popup.global_position = global_pos
	add_child(popup)


func _emit_signal_with_story_emit(signal_name):
	emit_signal(signal_name)


func _emit_shot_finished_with_story_emit(points):
	shot_finished.emit(points)


func _on_aim_repositioned():
	_emit_signal_with_story_emit("aim_repositioned")


func _add_agent(alias, is_player):
	var state_container = Utils.get_state_container_of(alias)

	if not state_container or _agents.has(alias):
		return

	state_container.dict.set_value("darts_score", 0)
	_agents[alias] = [state_container, is_player]


func _remove_agent(alias):
	if _active_agent_alias == alias:
		return

	_agents.erase(alias)
	_active_agent_alias = ""


func _set_current_agent(alias):
	if _state == States.IDLE:
		_state = States.AIMING_POSITION
	else:
		return

	var is_player = _agents[alias][1]
	crosshair.start(is_player)
	_active_agent_alias = alias


func _aim_position(aim_count, bullseye_tendency):
	if _state != States.AIMING_POSITION:
		return

	if ai.is_aim_active:
		ai.stop_aim()

	ai.aim(aim_count, bullseye_tendency)


func _start_aim_strength():
	if _state == States.AIMING_POSITION:
		_state = States.AIMING_STRENGTH
	else:
		return

	sfx_set_position.play()
	ai.aim_strength()


func _stop_aim():
	if _state != States.AIMING_POSITION:
		return

	ai.stop_aim()
	crosshair.stop()
	meter.stop()


func _throw(accuracy):
	if _state == States.AIMING_STRENGTH:
		_state = States.POST_AIM
	else:
		return

	ai.throw(accuracy)


func _remove_current_agent():
	if _state == States.POST_AIM:
		_state = States.IDLE
	else:
		return

	_active_agent_alias = ""
	crosshair.stop()
