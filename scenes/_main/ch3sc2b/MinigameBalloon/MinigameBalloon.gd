extends Node2D

signal aim_reposition
signal shot_finished(pts)

const TextPopup = preload("res://scenes/_main/ch3sc2a/scripts/TextPopup/TextPopup.tscn")

@export var crosshair_fade_duration := 0.5
@export var player_crosshair_tug_duration := 1.0
@export var player_crosshair_tug_max_distance := 100
@export var aim_interval_rand_min := 0.1
@export var aim_interval_rand_max := 0.5
@export var aim_reposition_duration_rand_min := 0.5
@export var aim_reposition_duration_rand_max := 1.5
@export var aim_fire_delay := 1
@export var joystick_aim_speed := 1000

@onready var crosshair = $Crosshair
@onready var balloons_placeholder = $BalloonsPlaceholder
@onready var balloons = $Balloons
@onready var ai = $AIController
@onready var focus = $Focus

@onready var sfx_balloon_pop = $SFX/BalloonPop
@onready var sfx_gun_reload = $SFX/GunReload
@onready var sfx_gun_shot = $SFX/GunShot
@onready var sfx_pellet_hits_wood = $SFX/PelletHitsWood

var _agents = {}
var _active_agent_alias: String
var _shoot_probability: float
var _rng = RandomNumberGenerator.new()
var _tugged_enabled: bool


func _ready():
	crosshair.balloons_placeholder = balloons_placeholder
	crosshair.fade_duration = crosshair_fade_duration
	crosshair.joystick_aim_speed = joystick_aim_speed
	crosshair.focus = focus

	ai.balloons = balloons
	ai.crosshair = crosshair
	ai.aim_interval_rand_min = aim_interval_rand_min
	ai.aim_interval_rand_max = aim_interval_rand_max
	ai.aim_reposition_duration_rand_min = aim_reposition_duration_rand_min
	ai.aim_reposition_duration_rand_max = aim_reposition_duration_rand_max
	ai.aim_fire_delay = aim_fire_delay

	crosshair.fire.connect(_on_fired)

	ai.fire.connect(_on_fired)
	ai.aim_reposition.connect(_on_aim_repositioned)

func start():
	visible = true
	focus.push()


func set_focus(focus):
	crosshair.focus = focus


func stop():
	focus.pop()
	_stop_aim()
	visible = false


func _on_fired():
	if crosshair.is_tugging or not _active_agent_alias in _agents.keys():
		return

	var active_agent = _agents[_active_agent_alias]
	var target_balloon = crosshair.balloon
	var is_player = active_agent[1]
	var pts = 0

	if _tugged_enabled and is_player:
		await ai.reposition_tugged(crosshair.position, player_crosshair_tug_duration, player_crosshair_tug_max_distance)

		sfx_gun_shot.play()
		crosshair.flash()
	else:
		sfx_gun_shot.play()
		await crosshair.flash()

	if crosshair.balloon:
		var hit = false

		if not is_player:
			hit = randf() <= _shoot_probability
		else:
			hit = true

		if hit:
			crosshair.balloon.pop()

			var state_container = active_agent[0]
			var score = state_container.dict.get_value("balloon_pop_score")

			pts = crosshair.balloon.score
			score = score + pts

			state_container.dict.set_value("balloon_pop_score", score)
			_popup_score(pts)

	if pts > 0:
		sfx_balloon_pop.play()
	else:
		sfx_pellet_hits_wood.play()

	shot_finished.emit(pts)


func _on_aim_repositioned():
	aim_reposition.emit()


func _restore_balloons():
	for balloon in balloons.get_children():
		balloon.restore()


func _popup_score(pts: int):
	var text_popup = TextPopup.instantiate()
	text_popup.position = crosshair.position
	text_popup.text = str(pts)
	add_child(text_popup)


func _add_agent(alias, is_player):
	var state_container = Utils.get_state_container_of(alias)

	if not state_container or _agents.has(alias):
		return


	state_container.dict.set_value("balloon_pop_score", 0)
	_agents[alias] = [state_container, is_player]


func _remove_agent(alias):
	if _active_agent_alias == alias:
		return

	_agents.erase(alias)
	_active_agent_alias = ""


func _remove_current_agent():
	_active_agent_alias = ""
	_stop_aim()


func _set_current_agent(alias):
	if _active_agent_alias != "":
		return

	if not _agents.has(alias):
		return

	var is_player = _agents[alias][1]
	crosshair.start(is_player)
	sfx_gun_reload.play()
	_active_agent_alias = alias


func _aim_and_fire(aim_count):
	var force_shake = _agents[_active_agent_alias][1]
	crosshair.start(false, force_shake)
	await ai.aim(aim_count)


func _stop_aim():
	ai.stop_aim()
	crosshair.stop()
