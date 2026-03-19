extends Node2D

signal back_button_clicked
signal playback_state_changed(state)

const icon_play = preload("res://assets/ui/ic_play.png")
const icon_pause = preload("res://assets/ui/ic_pause.png")

@onready var tone_selector = $Back/ToneSelector
@onready var winding_key = $Back/WindingKey
@onready var pendulum_pivot = $Front/PendulumPivot
@onready var tempo_label = $HBoxContainer/TempoLabel
@onready var start_btn = $HBoxContainer/StartButton
@onready var start_btn_icon = start_btn.get_node("Content/Icon")
@onready var back_btn = $BackButton

var current_energy = 0
var current_tempo
var is_playing = false:
	set(v):
		is_playing = v
		playback_state_changed.emit(is_playing)

var time_signature = "2/4"

#exposed vars for syncing with the rhythm minigame
################################################
var time_to_next_beat_ms: float = 0  : get = get_time_to_next_beat_ms


func get_time_to_next_beat_ms():
	return pendulum_pivot.time_to_next_beat_ms()


var beats_to_next_emphasis: float = 0 : get = get_beats_to_next_emphasis


func get_beats_to_next_emphasis():
	return pendulum_pivot.beats_to_next_emphasis()


var beat_duration_ms: float = 0 : get = get_beat_duration_ms


func get_beat_duration_ms():
	return 60.0 / current_tempo


var beat_measure: int = 2 : get =  get_beat_duration_ms


func get_beat_measure():
	return pendulum_pivot.beat_measure


#convenience func
func get_time_to_next_emphasized_beat():
	return get_time_to_next_beat_ms() + get_beats_to_next_emphasis() * get_beat_duration_ms()


#
################################################


func _ready():
	tone_selector.tone_selector_interacted.connect(_on_tone_selector_interacted)
	winding_key.winding_key_interacted.connect(_on_winding_key_interacted)
	pendulum_pivot.tempo_updated.connect(_on_tempo_update)
	start_btn.pressed.connect(_on_start_button_clicked)
	back_btn.button_down.connect(_on_back_button_clicked)
	pendulum_pivot.set_tempo()
	check_spring_energy()


func _process(delta):
	if is_playing:
		if current_energy <= 0:
			current_energy = 0
			stop_metronome()
		else:
			current_energy -= delta


func start_metronome():
	is_playing = true
	start_btn_icon.texture = icon_pause
	pendulum_pivot.start_swing()


func stop_metronome():
	is_playing = false
	start_btn_icon.texture = icon_play
	pendulum_pivot.stop_swing()
	check_spring_energy()


func disable_interaction(enable):
	tone_selector.disable_interaction(enable)
	winding_key.disable_interaction(enable)


func check_spring_energy():
	if current_energy <= 5:
		start_btn.visible = false
	else:
		start_btn.visible = true


func update_tempo():
	tempo_label.text = time_signature + " " + str(current_tempo) + " BPM"


func _on_tone_selector_interacted(time_signature):
	self.time_signature = time_signature
	var beat_measure = time_signature.left(1)
	pendulum_pivot.set_beat_measure(beat_measure.to_int())
	update_tempo()


func _on_winding_key_interacted(energy_increase):
	current_energy += energy_increase
	check_spring_energy()


func _on_tempo_update(tempo):
	current_tempo = tempo
	update_tempo()


func _on_start_button_clicked():
	is_playing = !is_playing

	if is_playing:
		start_metronome()
	else:
		stop_metronome()


func _on_back_button_clicked():
	back_button_clicked.emit()

func fade_out_volume():
	pendulum_pivot.fade_out_vol()

func fade_in_volume():
	pendulum_pivot.fade_out_vol()
