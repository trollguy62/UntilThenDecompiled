extends Node2D

signal pressed(which)

@export var voice_streams: Array[AudioStream] = []

@onready var voice_player = $VoicePlayer

var is_voice_enabled := true

var is_enabled = false:
	set(v):
		for c in get_children():
			if c is TextureButton:
				c.disabled = !v

		is_enabled = v


func _ready():
	var i = 0

	for child in get_children():
		if child is TextureButton:
			child.pressed.connect(_on_button_pressed.bind(i))
			child.pressed.connect(child.release_focus)
			i = i + 1

	assert(i == 10)
	assert(i == voice_streams.size())


func _on_button_pressed(which: int):
	_play_voice(which)
	pressed.emit(which)



func _play_voice(which: int):
	if is_voice_enabled:
		voice_player.stream = voice_streams[which]
		voice_player.play()
