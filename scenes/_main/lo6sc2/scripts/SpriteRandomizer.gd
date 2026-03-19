extends Node

@export var min_interval: float = 4
@export var max_interval: float = 10

var timer = Timer.new()

var _sprite
var _animations


func _ready():
	_sprite = get_parent()
	assert(_sprite is AnimatedPaper3D)
	_animations = _sprite.texture_frames.get_animation_names()
	timer.autostart = true
	timer.timeout.connect(_on_wait_timer_timeout)
	add_child(timer)

func _on_wait_timer_timeout():
	if _animations.size() > 0:
		timer.wait_time = randf_range(min_interval, max_interval)
		_sprite.animation = _animations[randi_range(0, _animations.size() - 1)]
