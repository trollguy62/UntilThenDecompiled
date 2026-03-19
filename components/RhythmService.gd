extends Node

signal game_started
signal game_stopped

const RhythmChartPivot = preload("res://components/RhythmChartPivot.gd")
const RhythmChart = preload("res://components/RhythmMinigame/RhythmChart.tscn")

var _command_handler = _run_command

#FIXME: temporary, probably better reading from a file/resource
@export var song_map: Dictionary = {}

var _pivots: Array = []  #Array of RhythmChartPivots
#FIXME: assumption is that there's only one running at a time
var _rhythm_chart  #RhythmChart scene

var forced_start_delay_ms: float = 0  #for syncing with the metronome, should be set by a higher level script
var _last_song_key_played := ""


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _ready():
	_rhythm_chart = RhythmChart.instantiate()
	#FIXME: hack
	await get_tree().process_frame
	#
	assert(!_pivots.is_empty())

	_pivots[0].add_child(_rhythm_chart)
	for p in _pivots:
		if p.visible:
			_rhythm_chart.reparent(p)
	
	_on_rhythm_settings_changed()
	Game.config.rhythm_settings_changed.connect(_on_rhythm_settings_changed)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _on_rhythm_settings_changed():
	_rhythm_chart.beatmap_renderer.scroll_speed = Game.config.rhythm_lane_speed_mult


func add(rhythm_chart_pivot: RhythmChartPivot):
	assert(rhythm_chart_pivot.get_custom_class() == "RhythmChartPivot")
	if rhythm_chart_pivot in _pivots:
		return
	_pivots.append(rhythm_chart_pivot)

func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"rhythm_game_start":
			game_started.emit()
			var song_key: String = params[0]
			var no_wait = flags.has("no-wait")

			if !(song_key in song_map):
				printerr("Could not find song with key: ", song_key, "!")
				return null

			#FIXME: hack
			if !_rhythm_chart.is_inside_tree():
				_pivots[0].add_child(_rhythm_chart)
			##
			_last_song_key_played = song_key
			_rhythm_chart.play(song_map[song_key], false, forced_start_delay_ms)
			print("Now playing: ", song_key)

			if not no_wait:
				await _rhythm_chart.rendering_finished

		"rhythm_game_get_accuracy":
			return _rhythm_chart.get_last_playthrough_score()

		"rhythm_game_is_score_perfect":
			return _rhythm_chart.is_score_perfect()

		"rhythm_game_stop":
			stop_game()

		_:
			return Constants.CMD_RETURN_NONE

	return null


func stop_game():
	if !_rhythm_chart.is_inside_tree():
		printerr("Rhythm chart does not exist in node tree!")
		return null
	_rhythm_chart.stop()
	game_stopped.emit()



func is_playing():
	return _rhythm_chart.is_playing()


func get_last_song_key_played() -> String:
	return _last_song_key_played


func _on_visibility_changed(which: RhythmChartPivot, visibility: bool):
	if _rhythm_chart == null:
		return
	if visibility && _rhythm_chart.is_inside_tree():
		for p in _pivots:
			if p == which:
				continue
			p.visible = false

		_rhythm_chart.reparent(which)

func get_rhythm_chart():
	return _rhythm_chart
