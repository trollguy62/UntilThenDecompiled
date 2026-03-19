extends Scene

#FIXME: due to how scenes are arranged in trees
#this blob of encap breaking code is required to pass data between minigames
@onready var metronome = get_node("Skits/Practice (12-16)/Root2D/C2D/Metronome")
@onready var rhythm_service = Service.of("RhythmService")
@onready var _rhythm_chart


func _ready():
	#FIXME: breaks encap
	super._ready()
	_rhythm_chart = rhythm_service.get_rhythm_chart()

	rhythm_service.game_started.connect(_on_pb_started)
	rhythm_service.game_stopped.connect(_on_r_finished)
	_rhythm_chart.rendering_finished.connect(_on_r_finished)


func _process(delta):
	if not metronome.is_playing:
		rhythm_service.forced_start_delay_ms = 0
		return


func calc_sync_delay():
	var time_to_next_emphasized_beat = metronome.get_time_to_next_emphasized_beat()
	var beat_measure = metronome.get_beat_measure()  #number of beats in a measure
	var metronome_beat_duration = metronome.get_beat_duration_ms()

	var audio_lead_in = _rhythm_chart.get_beatmap_audio_lead_in()
	var timing_point = _rhythm_chart.get_beatmap_timing_point_ms()
	var beat_duration = _rhythm_chart.get_beatmap_beat_duration_ms()

	var delay_ms = (timing_point + audio_lead_in) % (metronome_beat_duration * beat_measure)
	delay_ms -= time_to_next_emphasized_beat + beat_duration

	return delay_ms

func _on_pb_started():
	pausable = false

func _on_r_finished():
	#FIXME: hack
	await get_tree().create_timer(1).timeout
	pausable = true
