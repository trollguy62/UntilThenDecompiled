extends Node3D

const BASE_BUTTON_WIDTH = 40.0
const PULSE_MAX_BONUS_WDITH = 10.0
const CONTROLLER_WIDTH_MULTIPLIER = 1.0
const KB_WIDTH_MULTIPLIER = 1.75

@export var game_time: int = 60

@onready var mark_path = $Path/MarkPath
@onready var nicole_path = $Path/NicolePath
@onready var hud = $HUD
@onready var speed_meter = $HUD/CanvasLayer/Control/SpeedMeter
@onready var button_hint = $HUD/CanvasLayer/Control/ButtonHint
@onready var game_timer = $Timer
@onready var _scene = Utils.get_root_scene()

var _skit_container: SkitContainer
var min_dist_to_lead = 0.2
var is_started: bool = false
var is_paused: bool = false
var distance = 0.0
var current_leading
var last_lead
var has_lead_change
var mark = "Mark"
var nicole = "Nicole"


var _t = 0

func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container
	_skit_container.emitted.connect(_on_skit_emitted)


func _ready():
	speed_meter.speed_multiplier_changed.connect(_on_speed_multiplier_changed)
	game_timer.timeout.connect(_on_timer_timeout)
	current_leading = nicole
	last_lead = nicole


func _on_skit_emitted(name: String, value):
	match name:
		"start_minigame_bike":
			start()
	match name:
		"pause_minigame_bike":
			pause(true)
			hud.hide()
	match name:
		"resume_minigame_bike":
			pause(false)
			hud.show()
	match name:
		"move_nicole":
			nicole_path.move_to(value)
	match name:
		"move_mark":
			mark_path.move_to(value)


func _process(delta):
#	if is_started:
#		process_game_ui()

	if not is_paused:
		distance = mark_path.path_position - nicole_path.path_position
		current_leading = mark if distance > min_dist_to_lead else nicole

		if current_leading == last_lead:
			has_lead_change = false
		else:
			last_lead = current_leading
			has_lead_change = true
			lead_change()

	#makes button_hint pulse
	var width_multipler = KB_WIDTH_MULTIPLIER if Input.get_connected_joypads().is_empty() else CONTROLLER_WIDTH_MULTIPLIER
	button_hint.max_width = (BASE_BUTTON_WIDTH + (sin(_t * 4.0) + 1.0) * 0.5 * PULSE_MAX_BONUS_WDITH) * width_multipler
	_t += delta
	#

func _input(event):
	if is_paused:
		return

	if event.is_action("ui_select"):
		_t = 0
		if not event.is_pressed() and is_started:
			speed_meter.increase_speed_meter()



func start():
	is_started = true
	mark_path.disabled = false
	nicole_path.disabled = false
	speed_meter.start()
	game_timer.start(game_time)


func pause(enable):
	mark_path.disabled = enable
	nicole_path.disabled = enable
	speed_meter.set_active(enable)
	is_paused = enable
	game_timer.paused = enable


func stop():
	is_started = false
	mark_path.stop()
	nicole_path.stop()
	speed_meter.stop()
	button_hint.visible = false


func lead_change():
	_skit_container.emit_local("leading", current_leading)


func process_game_ui():
	if mark_path.is_talking() or nicole_path.is_talking():
		hud.hide()
		pause(true)

	if not mark_path.is_talking() and not nicole_path.is_talking():
		hud.show()
		pause(false)


func _on_speed_multiplier_changed(mark_multiplier, nicole_multiplier):
	mark_path.set_speed_multiplier(mark_multiplier)
	nicole_path.set_speed_multiplier(nicole_multiplier)


func _on_timer_timeout():
	_skit_container.emit_local("minigame_bike_finished")

	var player_won = current_leading == mark
	Store.set_value("state://ch5sc6/bike_win", player_won)

	if player_won:
		Game.dist_platform.unlock_achievement("ACH_BIKE_WIN")

	stop()
