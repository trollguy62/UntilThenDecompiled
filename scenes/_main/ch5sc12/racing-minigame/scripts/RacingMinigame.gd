extends Node3D

signal countdown_started(timer)
signal game_finished(result)
signal event_emitted(ev)

@export var laps : int = 3
@export var start_delay : float = 2
@export var lap_time_limit : int = 30

@onready var countdown_timer = $CountdownTimer
@onready var hud = $Splitscreen/VBoxContainer/Mark/HUD
@onready var racing_manager = $RacingManager
@onready var mark_hud = $Splitscreen/VBoxContainer/Mark/HUD
@onready var mark = $RacingManager/PathProjectors/MRK
@onready var cathy_hud = $Splitscreen/VBoxContainer/Cathy/HUD
@onready var cathy = $RacingManager/PathProjectors/CTH
#@onready var label = $CarMesh/Label3D
@onready var racing_soundtrack = $Audio/RacingMain
@onready var cathy_drift = $Audio/CathyDrift
@onready var player_mark = $RacingManager/Players/MRK

var timer = 5


func _ready():
	connect_signals(mark, mark_hud)
	connect_signals(cathy, cathy_hud)
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	racing_manager.game_ended.connect(_on_game_end)
	racing_manager.set_time_limit(lap_time_limit)
	racing_manager.set_total_laps(laps)
	racing_manager.init()


func connect_signals(player, hud):
	countdown_started.connect(hud._on_countdown_display)
	player.rank_changed.connect(hud._on_rank_changed)
	player.lap_completed.connect(hud._on_lap_completed)
	player.timer_changed.connect(hud._on_timer_changed)
	player.time_out.connect(hud._on_timeout_trigger)
	player.race_finished.connect(hud._on_race_finished)
	player.wrong_way.connect(hud._on_wrong_way)
	player.event_emitted.connect(_on_event_emitted)
	player.velocity_changed.connect(hud._on_velocity_changed)
	hud.set_lap_display(1, laps)


func start_game():
	racing_manager.pre_start_race()
	racing_soundtrack.play()
	await get_tree().create_timer(start_delay).timeout
	start_countdown()


func start_countdown():
	countdown_started.emit(timer)
	racing_soundtrack.set_parameter("race_start", 1)
	countdown_timer.start(1)


func _on_countdown_timer_timeout():
	timer -= 1

	if timer == 0:
		countdown_timer.stop()
		racing_manager.start_race()


func _on_game_end(result):
	game_finished.emit(result)
	player_mark.stop_engine_sound()
	$TimeoutSound.play()
	#FIXME: Hack, but Cathy never wins anw so...
	racing_soundtrack.set_parameter("race_mark_winner", 1)
	#
	racing_soundtrack.set_parameter("race_finish", 1)
	for i in result.size():
		print(
			(
				"Name: "
				+ result[i].name
				+ "    "
				+ "Rank: "
				+ str(i + 1)
				+ "   "
				+ " Time: "
				+ str(result[i].time)
			)
		)


func _on_event_emitted(ev):
	event_emitted.emit(ev)
	
	if ev == "Drift":
		cathy_drift.play()


func pause_game(is_paused):
	racing_manager.pause_game(is_paused)
	racing_soundtrack.playing = is_paused
