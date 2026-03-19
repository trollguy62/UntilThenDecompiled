extends Node

@export var animation_trigger: String
@export var interval_between_plays: float = 1.0

@onready var animation = get_parent()
@onready var timer = $Timer

var playlist: Array[AudioStreamPlayer3D]
var audio_index: int
var is_playing = false


func _ready():
	for audio in get_children():
		if audio is AudioStreamPlayer3D:
			playlist.append(audio)

	animation.animation_changed.connect(_on_animation_changed)
	timer.timeout.connect(_on_timer_timeout)


func _on_animation_changed(animation_name):
	if animation_trigger != animation_name:
		is_playing = false
		timer.stop()
	else:
		is_playing = true
		play_audio()
		timer.start(interval_between_plays)


func _on_timer_timeout():
	if is_playing:
		play_audio()


func play_audio():
	audio_index = randi_range(0, playlist.size()-1)
	playlist[audio_index].play()
