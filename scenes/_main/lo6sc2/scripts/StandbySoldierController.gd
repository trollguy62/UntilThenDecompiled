extends Node3D

@export var min_interval = 1.0
@export var max_interval = 4.0

var timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	randomize_sprite()
	timer.wait_time = randf_range(min_interval, max_interval)
	timer.start()

func randomize_sprite():
	var spr = $Sprite
	var anims = spr.texture_frames.get_animation_names()
	if anims.size() > 0:
		spr.animation = anims[randi_range(0, anims.size() - 1)]
