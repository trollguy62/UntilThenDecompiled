extends VideoStreamPlayer

signal paused_changed(paused)
#warning-ignore:unused_signal
signal fullscreen_toggled()

const START_OFFSET = 0.16
const STOP_OFFSET = 0.04

@onready var parent = get_parent()
@onready var play_pause_area = $PlayPauseBtn
@onready var _last_paused = self.paused

@export var video_ref: String:
	set = _set_video_ref,
	get = _get_video_ref
@export var fullscreen = false:
	get: return fullscreen
@export var auto_replay = false

var video_size: Vector2:
	get: return get_video_texture().get_size()
var playback_progress: float:
	get: return stream_position / self.video_length
var video_length: float:
	get: return video_length
var time_elapsed: float:
	get: return stream_position
var time_remaining: float:
	get: return self.video_length - self.time_elapsed
var is_finished: bool:
	get: return self.time_remaining <= STOP_OFFSET

var _is_ready = false


func _ready():
	paused_changed.connect(_on_paused_changed)
	play_pause_area.pressed.connect(_on_play_pause_area_pressed)

	self.video_ref = video_ref


func _process(delta):
	if _last_paused != self.paused:
		paused_changed.emit(self.paused)
	_last_paused = self.paused

	if is_playing() and self.is_finished:
		if auto_replay:
			play()
		else:
			self.paused = true


func _set_video_ref(value):
	video_ref = value
	if play_pause_area == null or video_ref.is_empty():
		return

	self.stream = load(video_ref)
	video_length = 15.5  # TODO get from video

	play()
	if not autoplay:
		await Utils.wait(START_OFFSET)
		self.paused = true


func _get_video_ref():
	return video_ref


func _on_paused_changed(paused: bool):
	if not paused and self.is_finished:
		play()


func _on_play_pause_area_pressed():
	self.paused = not self.paused
