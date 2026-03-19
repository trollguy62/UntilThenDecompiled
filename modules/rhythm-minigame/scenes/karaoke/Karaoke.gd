extends Node2D

signal pending_song_changed(id)

const OsuBeatmap = preload("../../classes/beatmap/OsuBeatmap.gd")
const OsuHitObject = preload("../../classes/beatmap/OsuHitObject.gd")
const HitResult = preload("../../classes/judgment/HitResult.gd")
const LrcObject = preload("../../classes/lrc/LrcObject.gd")
const KaraokeSong = preload("./KaraokeSong.gd")

@export var lyric_lead_in: float = 3000.0  #ms
@export var user_offset_ms: float = 0.0

@onready var karaoke_buttons := $Anchor/KaraokeButtons
@onready var led := $Anchor/LED
@onready var input_timer: Timer = $InputTimeout
@onready var selection_timer: Timer = $SelectionTimeout
@onready var initial_playback_delay_timer = $InitialPlaybackDelayTimer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var extra_buttons := {
	"Clap": $Anchor/ExtraButtons/Clap,
	"Horn": $Anchor/ExtraButtons/Horn,
	"Play": $Anchor/ExtraButtons/Play,
	"Stop": $Anchor/ExtraButtons/Stop,
}

@onready var soundboard := {"Clap": $Anchor/Soundboard/Clap, "Horn": $Anchor/Soundboard/Horn}

@onready var sfx_button_press := $Anchor/SFX/ButtonPress

@onready var karaoke_viewport = $Viewport
@onready var karaoke_display = $Viewport/KaraokeDisplay

@onready var kstate_machine = $KStateMachine
@onready var idle = karaoke_display.idle
@onready var sing = karaoke_display.sing
@onready var scoring = karaoke_display.scoring

@onready var logo = karaoke_display.logo

@onready var song_info = karaoke_display.song_info
@onready var popular_songs = karaoke_display.popular_songs

@onready var rhythm_anchor = karaoke_display.rhythm_anchor
@onready var song_queue = karaoke_display.song_queue
@onready var top_bar_input = karaoke_display.top_bar_input
@onready var sing_initial_screen = karaoke_display.sing_initial_screen

@onready var score_screen = karaoke_display.score_screen

var timestamp_msec: float = 0:
	set(v):
		timestamp_msec = v
		if not is_inside_tree():
			await ready

		rhythm_anchor.timestamp_msec = v

var lrc: LrcObject
var index: int = 0

var beatmap: OsuBeatmap
var hit_objects: Array
var audio_latency: float = 0


var pending_song: int = -1:
	set(value):
		pending_song = value
		pending_song_changed.emit(value)

var is_soundboard_enabled := true

var score: Dictionary = {
	"perfect": 0,
	"great": 0,
	"miss": 0,
}

var current_song_id := -1
var last_completed_song_id := -1
var last_score := 0

#FIXME: test db
var song_db: Dictionary = {
	1357:
	KaraokeSong.new(
		"Auld Lang Syne",
		"Robert Burns",
		1357,
		"res://modules/rhythm-minigame/assets/maps/Auld Lang Syne/Robert Burns - Auld Lang Syne (Pkmn05) [4k Normal].osu",
		"res://modules/rhythm-minigame/assets/maps/Auld Lang Syne/AuldLangSyne.lrc"
	),
	9843:
	KaraokeSong.new(
		"Bahay Kubo",
		"Folk Song",
		9843,
		"res://modules/rhythm-minigame/assets/maps/Bahay Kubo/Folk Song - Bahay Kubo (Me) [Normal].osu",
		"res://modules/rhythm-minigame/assets/maps/Bahay Kubo/Bahay-Kubo.lrc"
	),
	1203:
	KaraokeSong.new(
		"Leron Leron Sinta",
		"Folk Song",
		1203,
		"res://modules/rhythm-minigame/assets/maps/LeronLeronSinta/Folk Song - Leron Leron Sinta (me) [Normal].osu",
		"res://modules/rhythm-minigame/assets/maps/LeronLeronSinta/Leron-Leron-Sinta.lrc"
	),
}
##


func _ready():
	for c in rhythm_anchor.get_children():
		c.new_result.connect(_on_new_result)

	$Viewport/KaraokeDisplay.display_size = $Anchor/KaraokeDisplay.get_rect().size

	karaoke_buttons.pressed.connect(_on_karaoke_button_pressed)
	popular_songs.songs = song_db.values()

	for sfx in ["Clap", "Horn"]:
		extra_buttons[sfx].pressed.connect(_on_sfx_button_pressed.bind(sfx))

	for button in extra_buttons.values():
		button.pressed.connect(_on_button_pressed)


func _unhandled_input(event):
	karaoke_viewport.push_input(event)


func get_audio_latency_msec() -> float:
	return (AudioServer.get_output_latency() + AudioServer.get_time_to_next_mix()) * 1000.0


func stop():
	kstate_machine.reset()
	var streams = []
	Utils.get_descendants_of_type(self, "AudioStreamPlayer", streams)

	for stream in streams:
		stream.stop()

	selection_timer.stop()


func _on_karaoke_button_pressed(which: int):
	_on_button_pressed()
	led.push_digit(which)
	self.pending_song = led.value


func _on_sfx_button_pressed(sfx: String):
	(soundboard[sfx] as AudioStreamPlayer).play()


func _on_button_pressed():
	sfx_button_press.play()


func _on_new_result(result):
	match result.type:
		HitResult.HIT_RESULT_PERFECT:
			score.perfect += 1
		HitResult.HIT_RESULT_GREAT:
			score.great += 1
		HitResult.HIT_RESULT_MISS:
			score.miss += 1

func can_exit():
	return kstate_machine.current_state.name == "Idle"

func is_perfect_score():
	return score["perfect"] > 0 && score ["miss"] <= 0 && score["great"] <= 0


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	match cmd.name:
		"karaoke.get_last_completed_song_id":
			return last_completed_song_id
		"karaoke.get_last_score":
			return last_score
		_:
			return Constants.CMD_RETURN_NONE

	return null
