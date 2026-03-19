extends HBoxContainer

@onready var video_player: VideoStreamPlayer = get_parent()

@onready var playback_btn = $PlayPause
@onready var time_elapsed = $TimeElapsed
@onready var seek_bar = $SeekBar
@onready var time_remaining = $TimeRemaining
@onready var fullscreen_btn = $Fullscreen


func _ready():
	playback_btn.toggled.connect(_on_playback_btn_toggled)
	fullscreen_btn.pressed.connect(_on_fullscreen_btn_pressed)

	if video_player.fullscreen:
		fullscreen_btn.texture_normal = preload("res://assets/ui/ic_fullscreen_exit.png")


func _process(delta):
	if video_player == null:
		return

	playback_btn.button_pressed = not video_player.paused
	time_elapsed.text = _format_time(video_player.time_elapsed)
	time_remaining.text = "-" + _format_time(video_player.time_remaining)
	seek_bar.value = video_player.playback_progress


func _on_playback_btn_toggled(paused: bool):
	video_player.paused = not paused


func _on_fullscreen_btn_pressed():
	video_player.fullscreen_toggled.emit()


func _format_time(secs_f: float) -> String:
	secs_f = max(0.0, secs_f)
	var secs = int(floor(secs_f))
	var mins = int(floor(secs / 60.0))
	return "%01d:%02d" % [mins, secs % 60]
