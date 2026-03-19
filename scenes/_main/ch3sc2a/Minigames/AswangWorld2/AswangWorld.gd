extends Node2D

signal game_finished(win_state)

const TextPopup = preload("res://scenes/_main/ch3sc2a/scripts/TextPopup/TextPopup.tscn")

const WIN_STATE_TIE = 0
const WIN_STATE_PLAYER = 1
const WIN_STATE_AI = 2

@export var max_npc = 5
@export var game_time = 100
@export var owned_ai_color: Color
@export var owned_player_color: Color
@export var player_can_move = true : set = set_player_can_move
@export var autoplay_bgm_tutorial = true
@export var npc_scenes : Array[PackedScene]

@export var player_state_container_alias = ""
@export var ai_state_container_alias = ""

@onready var tilemap = $TileMaps/TileMap
@onready var player = $Player
@onready var ai = $AI
@onready var npc_group = $NPCs
@onready var waypoints = $WayPoints
@onready var respawn_point = $RespawnPoint
@onready var timer_respawn = $TimerRespawn
@onready var hud = $HUD
@onready var camera = $Player/Camera2D

@onready var sfx_npc_enter = $SfxNpcEnter
@onready var sfx_player_score = $SfxPlayerScore
@onready var sfx_ai_score = $SfxAiScore

@onready var player_state_container = Utils.get_state_container_of(player_state_container_alias)
@onready var ai_state_container = Utils.get_state_container_of(ai_state_container_alias)

@onready var _initial_player_position = player.position

var _npcs = []
var _waypoints = []
var _last_npc_index = -1

var score_player = 0
var score_ai = 0

var _game_aborted = false


func _ready():
	for p in waypoints.get_children():
		_waypoints.append(p.position)

	for npc in npc_group.get_children():
		_set_npc_properties(npc)

	if ai:
		ai.path_finder.tilemap = tilemap
		ai.npcs = _npcs
		ai.waypoints = _waypoints

	hud.seconds = game_time

	timer_respawn.timeout.connect(_on_respawn_timedout)
	hud.time_finish.connect(_on_time_timedout)

	_stop_agents()
	npc_group.visible = false
	hud.ui_visible = false

	if autoplay_bgm_tutorial:
		play_bgm_tutorial()


func _process(delta):
	var is_visible_in_tree = is_visible_in_tree()
	camera.enabled = is_visible_in_tree

	if _game_aborted: # very amazing hack
		player.can_move = false


func play_bgm_tutorial():
	$BGMTutorial.play()


func start_game():
	timer_respawn.start()
	hud.timer_time_left.start()
	_resume_agents()

	npc_group.visible = true
	hud.ui_visible = true

	$BGMTutorial.stop()
	$BGMMain.play()


# Only used in 8.2b
func abort_game():
	camera.position = Vector2(0, 0)
	hud.ui_visible = false

	for node in [npc_group, ai, player]:
		if is_instance_valid(node):
			node.visible = false

	$BGMTutorial.stop()
	$BGMMain.stop()
	_stop_agents()

	player.position = _initial_player_position
	_game_aborted = true


func _set_npc_properties(npc):
	npc.path_finder.tilemap = tilemap
	npc.owned_ai_color = owned_ai_color
	npc.owned_player_color = owned_player_color
	npc.waypoints = _waypoints
	npc.exit.connect(_on_npc_exited)
	npc.zero_tolerance.connect(_on_npc_zero_tolerance.bind(npc))
	_npcs.append(npc)


func _on_npc_exited(npc):
	_npcs.remove_at(_npcs.find(npc))


func _on_npc_zero_tolerance(owned_by: String, npc: Node2D):
	var owned_by_player = owned_by == "Player"
	var owned_color = owned_player_color if owned_by_player else owned_ai_color

	_increase_score(owned_by_player, 1)
	_popup_text("+1", npc.global_position, owned_color)
	_adjust_ai_int()


func _increase_score(player: bool, pts: int):
	var state_container = player_state_container if player else ai_state_container
	var new_score = 0

	if player:
		score_player += 1
		new_score = score_player
		sfx_player_score.play()
	else:
		score_ai += 1
		new_score = score_ai
		sfx_ai_score.play()

	if state_container is StateContainer:
		state_container.dict.set_value("aswang_world_score", new_score)


func _popup_text(text: String, global_pos: Vector2, color: Color):
	var popup = TextPopup.instantiate()
	popup.text = text
	popup.global_position = global_pos
	popup.modulate = color
	popup.z_index = 3
	popup.scale = Vector2.ONE * 0.4
	add_child(popup)


func _adjust_ai_int():
	var score_diff = score_player - score_ai
	if score_diff >= 2:
		ai.intelligence += 10
	elif score_diff <= 2:
		ai.intelligence -= 10

	ai.intelligence = clamp(ai.intelligence, 0, 100)


func _on_respawn_timedout():
	# keep the queue full all the time
	if _npcs.size() < max_npc:
		var new_npc = _get_npc()
		new_npc.position = respawn_point.position
		npc_group.add_child(new_npc)
		_set_npc_properties(new_npc)
		sfx_npc_enter.play()

		if ai:
			ai.npcs = _npcs



func _get_npc() -> Node2D:
	var npc_index = randi() % npc_scenes.size()

	while _last_npc_index == npc_index:
		npc_index = randi() % npc_scenes.size()

	_last_npc_index = npc_index
	return npc_scenes[npc_index].instantiate()


func _on_time_timedout():
	timer_respawn.stop()
	_stop_agents()
	npc_group.queue_free()

	var win_state = (
		WIN_STATE_TIE
		if score_player == score_ai
		else (WIN_STATE_PLAYER if score_player > score_ai else WIN_STATE_AI)
	)
	game_finished.emit(win_state)


func _stop_agents():
	player.can_move = false
	ai.disabled = true
	for npc in npc_group.get_children():
		npc.disabled = true


func _resume_agents():
	player.can_move = player_can_move
	ai.disabled = false
	for npc in npc_group.get_children():
		npc.disabled = false


func set_player_can_move(value: bool):
	player_can_move = value

	if is_inside_tree():
		player.can_move = not ai.disabled and value
