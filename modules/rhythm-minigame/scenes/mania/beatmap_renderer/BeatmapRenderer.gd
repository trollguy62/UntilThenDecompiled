extends Node2D

signal rendering_finished

@export var beatmap_file_path: String = ""

@export var scroll_speed: float = 1.0:
	set(v):
		if not is_inside_tree():
			await ready
		scroll_speed = v
		four_key_play_area.scroll_speed_mult = scroll_speed

const OsuBeatmap = preload("res://modules/rhythm-minigame/classes/beatmap/OsuBeatmap.gd")
const OsuParser = preload("res://modules/rhythm-minigame/classes/parser/OsuParser.gd")
const OsuTimingPoint = preload("res://modules/rhythm-minigame/classes/beatmap/OsuTimingPoint.gd")

var beatmap: OsuBeatmap
var is_playing = false

var _timestamp_msec: int = 0
var _time_begin_msec: int = 0
var _audio_latency_msec: int = 0
var _is_autoplay_set = true

var _index: int = 0
var _autoplay_index: int = 0
var _beat_accumulator_ms: float = 0

@onready var asp: AudioStreamPlayer = $MusicStream
@onready var lead_in_timer: Timer = $LeadInDelay
@onready var play_area := $Visual/FourKeyPlayArea
@onready var four_key_play_area = $Visual/FourKeyPlayArea

## for metronome
@onready var metronome_tick = $MetronomeTick
@onready var metronome_tick_emphasis = $MetronomeTickEmphasis
var timing_pts: Array = []
var next_timing_pt: OsuTimingPoint
var current_beat: int = 0
var current_beat_len: float = -1.0
var current_meter: int = 4
var next_beat_in: int = 0 #ms
var metronome_enabled: bool = false
var is_paused: bool = false
var pause_offset: float = 0
##

func _ready():
	asp.finished.connect(_on_rendering_finished)


func _process(delta):
	if !is_playing:
		return

	if is_paused:
		pause_offset += delta
		return

	_timestamp_msec = asp.get_playback_position() * 1000.0 + _audio_latency_msec - Game.config.rhythm_offset_ms

	if metronome_enabled:
		_process_metronome(_timestamp_msec)

	play_area.timestamp_msec = _timestamp_msec


func _process_metronome(_timestamp_msec):
	if not timing_pts.is_empty():
		if _timestamp_msec > timing_pts.front().time:
			var old_beat_len = current_beat_len if current_beat_len > 0.0 else timing_pts.front().beatLength

			var adj_ratio = round(max(current_beat_len / old_beat_len, 1.0)) #prevents abrupt ticks from mismatched bpms

			next_timing_pt = timing_pts.pop_front()
			next_beat_in = beatmap.AudioLeadIn + next_timing_pt.time + next_timing_pt.beatLength * adj_ratio
			next_beat_in -= 150 #ms, hardcoded delay for sfx
			current_meter = next_timing_pt.meter
			current_beat_len = next_timing_pt.beatLength * 2 #no idea why it needs to be multiplied by 2 but it just does

	if _timestamp_msec >= next_beat_in and next_beat_in > 0:
		current_beat = current_beat % current_meter + 1

		#while this is correct, some beatmaps are labeled as 2/4 despite being 4/4 and sound not so great with emphasized ticks
		##so for the time being this is disabled
		if current_beat == 1:
			#metronome_tick_emphasis.play()
			metronome_tick.play()
		else:
			metronome_tick.play()

		next_beat_in += current_beat_len
		current_beat += 1


func play(osu_map_path: String, autoplay = false, start_delay_ms: float = 0):
	if is_playing:
		return

	var op = OsuParser.new()
	beatmap = op.parse_osu_from_path(osu_map_path)
	asp.stream = load(osu_map_path.get_base_dir() + "/" + beatmap.AudioFilename)
	asp.play()

	_time_begin_msec = Time.get_ticks_msec() + beatmap.AudioLeadIn

	lead_in_timer.wait_time = max(beatmap.AudioLeadIn / 1000.0 + start_delay_ms, 0)
	lead_in_timer.start()

	pause_offset = 0
	_index = 0
	_autoplay_index = 0
	play_area.hit_objects = beatmap.HitObjects.duplicate()

	is_playing = true
	_audio_latency_msec = (
		(AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		* 1000.0
	)

	play_area.start(autoplay)

	timing_pts = beatmap.TimingPoints.duplicate()

	current_beat = 0


func stop():
	if not is_playing:
		return

	asp.stop()
	lead_in_timer.stop()
	play_area.stop()

	#FIXME: might be redundant
	is_playing = false
	rendering_finished.emit()


func _on_rendering_finished():
	is_playing = false
	rendering_finished.emit()


func get_last_playthrough_score():
	return play_area.get_last_playthrough_score()

func is_score_perfect():
	return play_area.is_score_perfect()
