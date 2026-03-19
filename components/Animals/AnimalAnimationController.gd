extends Node

signal animation_changed(animation_name)

@export var min_interval := 0.0
@export var max_interval := 1.0
@export var animations: Array[String]
@export var randomize_animation: bool

@onready var sprite = get_parent()

@onready var _shuffled_anim_indices: Array = range(animations.size())

var timer = Timer.new()
var i = 0


func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	start_animation_cycle()


func start_animation_cycle():
	change_animation()


func stop_animation_cycle():
	timer.stop()


func _on_timeout():
	change_animation()


func change_animation():
	var anim: String

	if randomize_animation:
		if i == 0:
			_shuffled_anim_indices.shuffle()
		anim = animations[_shuffled_anim_indices[i]]
	else:
		anim = animations[i]

	await sprite.animation_finished
	sprite.animation = anim
	i = (i + 1) % animations.size()

	timer.start(randf_range(min_interval, max_interval))
	animation_changed.emit(anim)


func set_formatted_animation(anim: String):
	var flip_h = false

	if anim.begins_with("!"):
		flip_h = true
		anim = anim.trim_prefix("!")

	sprite.animation = anim
	sprite.flip_h = flip_h
