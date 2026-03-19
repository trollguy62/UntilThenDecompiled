@tool
extends AudioStreamPlayer3D

@export var streams: Array[AudioStream] = []
@export_range(0, 1024) var interval_min: float = 0.0
@export_range(0, 1024) var interval_max: float = 0.0


func _ready():
	finished.connect(_schedule_play)
	_schedule_play()


func _schedule_play():
	var interval = randf_range(interval_min, interval_max)
	await Utils.wait(interval)
	_play_random_stream()


func _play_random_stream():
	Utils.randomize()
	stream = streams[randi() % streams.size()]
	play()
