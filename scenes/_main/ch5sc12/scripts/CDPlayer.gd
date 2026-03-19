extends Node

@export var track_list : Array[Resource]

@onready var btn_play = $BtnPlayPause
@onready var btn_stop = $BtnStop
@onready var btn_prev = $BtnPrev
@onready var btn_next = $BtnNext
@onready var text_display = $TextDisplay
@onready var audioplayer: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

const DISPLAY_MAX_CHARS = 18

var current_playback = 0
var track_index = 0
var _skit_container: SkitContainer
var time = 0
var play_delay = 1
var trigger_short_count = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	audioplayer.stream = track_list[0]

	btn_play.button_down.connect(_on_play_button_down)
	btn_stop.button_down.connect(_on_stop_button_down)
	btn_prev.button_down.connect(_on_prev_button_down)
	btn_next.button_down.connect(_on_next_button_down)
	audioplayer.finished.connect(_on_audio_finished)
	timer.timeout.connect(play_music)
	update_display()


func _skit_ready(_skit_container: SkitContainer):
	self._skit_container = _skit_container
	self._skit_container.emitted.connect(_on_skit_emitted)


func _process(delta):
	if audioplayer.playing:
		time += delta
		var secs = fmod(time, 60)
		var mins = fmod(time, 60 * 60) / 60
		_set_display_text("%02d:%02d" % [mins, secs])
	else:
		if not get_track_name(track_list[track_index]) in text_display.text:
			update_display()


func pause():
	current_playback = audioplayer.get_playback_position()
	audioplayer.stop()


func stop():
	audioplayer.stop()
	current_playback = 0
	time = 0


func play():
	timer.start(1)
	update_display()


func play_music():
	if track_index < track_list.size() - 1:  # remove when we have cathy's voice audio
		audioplayer.play(current_playback)


func next():
	time = 0
	track_index = track_index + 1
	audioplayer.stream = track_list[track_index]

	if track_index == track_list.size() - 1:
		_skit_container.emit_local("cathy_cd")
		update_display()
		stop()  # remove when we have cathy's voice audio
	else:
		play()


func previous():
	if track_index == 0:
		return

	time = 0
	track_index = track_index - 1
	audioplayer.stream = track_list[track_index]
	play()


func update_display():
	_set_display_text(get_track_name(track_list[track_index]))


func _set_display_text(str: String):
	if str.length() >= DISPLAY_MAX_CHARS:
		str = str.substr(0, DISPLAY_MAX_CHARS)

	var spaces = DISPLAY_MAX_CHARS - str.length()
	var left_spaces = spaces / 2
	var right_spaces = spaces - left_spaces

	text_display.text = " ".repeat(left_spaces) + str + " ".repeat(right_spaces)


func _on_stop_button_down():
	if track_index == track_list.size() - 1:
		_start_short()
		return

	stop()


func _on_play_button_down():
	if track_index == track_list.size() - 1:
		_start_short()
		return

	if audioplayer.playing:
		pause()
	else:
		play()


func _on_prev_button_down():
	if track_index == track_list.size() - 1:
		_start_short()
		return

	previous()


func _on_next_button_down():
	if track_index == track_list.size() - 1:
		_start_short()
		return

	next()


func _on_audio_finished():
	next()


func _on_skit_emitted(name: String, value):
	match name:
		"play_music":
			play()
		"disable_dvd_interaction":
			_set_interaction_enabled(false)
		"enable_dvd_interaction":
			_set_interaction_enabled(true)


func _set_interaction_enabled(enabled: bool):
	for btn in [btn_play, btn_stop, btn_prev, btn_next]:
		btn.disabled = not enabled


func _start_short():
	if trigger_short_count >= 1:
		return
	if _skit_container != null and is_instance_valid(_skit_container):
		trigger_short_count += 1
		await _skit_container.start_short("mark_refuse_interact")


func get_track_name(resource: Resource):
	return resource.resource_path.get_file().trim_suffix(".ogg")
