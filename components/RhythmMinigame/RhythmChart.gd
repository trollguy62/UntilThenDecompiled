@tool
extends Control

signal rendering_finished
signal playback_started

@onready var beatmap_renderer = $BeatmapRenderer

var metronome_enabled = false:
	set(v):
		metronome_enabled = v
		beatmap_renderer.set_deferred("metronome_enabled", v)

#exposed values to sync with metronome
func get_beatmap_audio_lead_in():
	return beatmap_renderer.beatmap.AudioLeadIn


func get_beatmap_timing_point_ms():  #the time in ms after audio plays that beats are counted
	return beatmap_renderer.beatmap.TimingPoints[0]


func get_beatmap_beat_duration_ms():
	return beatmap_renderer.beatmap.TimingPoints[1]


#######################################


func _ready():
	Game.paused_changed.connect(_on_paused_changed)
	beatmap_renderer.rendering_finished.connect(on_rendering_finished)


func play(osu_map_path, autoplay = false, start_delay = 0):
	beatmap_renderer.play(osu_map_path, autoplay, start_delay)
	playback_started.emit()


func stop():
	beatmap_renderer.stop()


func get_last_playthrough_score():
	return beatmap_renderer.get_last_playthrough_score()

func is_score_perfect():
	return beatmap_renderer.is_score_perfect()

func is_playing():
	return beatmap_renderer and beatmap_renderer.is_playing

func on_rendering_finished():
	rendering_finished.emit()

func _on_paused_changed(paused):
	beatmap_renderer.is_paused = paused
