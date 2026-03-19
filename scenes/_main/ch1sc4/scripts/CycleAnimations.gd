extends Node

@export var mode: String = ""
@export var min_interval := 0.0
@export var max_interval := 1.0
@export var animations: Array[String]

@onready var sprite = get_parent()
@onready var state_container: StateContainer = Utils.get_state_container_of(sprite.alias)

var timer = Timer.new()
var i = 0
var is_playing = false


func _ready():
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timeout)

	state_container.changed.connect(_on_state_container_changed)
	_on_state_container_changed()


func _on_state_container_changed():
	var current_mode = state_container.dict.get_value("mode", "default")

	if current_mode == mode:
		if not is_playing:
			start_animation_cycle()
	else:
		stop_animation_cycle()


func start_animation_cycle():
	change_animation()
	is_playing = true


func stop_animation_cycle():
	timer.stop()
	is_playing = false


func _on_timeout():
	change_animation()


func change_animation():
	await sprite.animation_finished

	var anim = animations[i]
	set_formatted_animation(anim)

	i = (i + 1) % animations.size()
	timer.start(randf_range(min_interval, max_interval))


func set_formatted_animation(anim: String):
	var flip_h = false

	if anim.begins_with("!"):
		flip_h = true
		anim = anim.trim_prefix("!")

	sprite.animation = anim
	sprite.flip_h = flip_h
