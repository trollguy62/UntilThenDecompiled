@tool
extends CanvasItem

const TEMPO_EQUALITY_TOLERANCE := 2.0

@export var exit_button_nodepath: NodePath = ""
@export var metronome_nodepath: NodePath = ""
@export var song_key_to_initial_tempo := {} # Dictionary<String, float>
@export var enable_pause_to_stop = false

var _preview_loaded = false
var _preview
var _exit_btn
#FIXME: breaks encap
var _rs  #RhythmService
var _metronome
var _rc_is_playing

func _ready():
	#please make this node a canvas_item or derivative
	_exit_btn = get_node_or_null(exit_button_nodepath)
	#bit overkill to store a ref when we just need a bool but it works
	_metronome = get_node_or_null(metronome_nodepath)

	if _exit_btn:
		assert(_exit_btn is Button)
		_exit_btn.pressed.connect(_on_exit_btn_pressed)

	_rs = Service.of("RhythmService")
	_rs.add(self)

	#FIXME: breaks encap :(
	if _metronome and "is_playing" in _metronome:
		_metronome.playback_state_changed.connect(_on_metronome_playback_state_changed)
		await get_tree().process_frame
		_rs._rhythm_chart.playback_started.connect(_on_rc_playback_started)
		_rs._rhythm_chart.rendering_finished.connect(_on_rc_rendering_finished)

	#FIXME: breaks encap
	visibility_changed.connect(_rs._on_visibility_changed.bindv([self, visible]))

func _on_metronome_playback_state_changed(state):
	if not state:
		_rs._rhythm_chart.metronome_enabled = false

func _on_rc_playback_started():
	_rc_is_playing = true
	_rs._rhythm_chart.metronome_enabled = false

	var last_song_key = _rs.get_last_song_key_played()
	if not last_song_key in song_key_to_initial_tempo:
		return

	var expected_tempo = song_key_to_initial_tempo[last_song_key]
	var current_tempo = _metronome.current_tempo

	if current_tempo < expected_tempo - TEMPO_EQUALITY_TOLERANCE \
			or current_tempo > expected_tempo + TEMPO_EQUALITY_TOLERANCE:
		return

	if _metronome != null and _metronome.is_playing:
		_rs._rhythm_chart.metronome_enabled = true
		_metronome.fade_out_volume()

func _on_rc_rendering_finished():
	_rc_is_playing = false

	if _metronome != null:
		_metronome.stop_metronome()

func get_custom_class():
	return "RhythmChartPivot"


func _process(delta):
	if Engine.is_editor_hint():
		if not _preview_loaded:
			_preview = load("res://components/RhythmMinigame/RhythmChart.tscn").instantiate()
			add_child(_preview)
			_preview_loaded = true

		return

	if _exit_btn:
		_exit_btn.visible = _rs.is_playing()


func _on_exit_btn_pressed():
	_rs.stop_game()

func _input(event):
	if event.is_action_pressed("pause") and _rs.is_playing() and enable_pause_to_stop:
		_rs.stop_game()
