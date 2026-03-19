extends Node

@onready var timer: Timer = $Timer
@onready var audio_event = get_parent()

@export var min_interval: float = 20
@export var max_interval: float = 40


func _ready():
	timer.timeout.connect(_on_timer_timeout)
	start_timer()


func _on_timer_timeout():
	play_audio()


func play_audio():
	audio_event.play()
	start_timer()


func start_timer():
	timer.start(get_random_interval())


func get_random_interval():
	return randf_range(min_interval, max_interval)
