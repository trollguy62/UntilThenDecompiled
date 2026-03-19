extends Node

@export var sprite_path: NodePath
@export var state_path: NodePath
@export var default_idle_anim: String
@export var default_talk_anim: String
@export var look_around_anims: Array[String] = []
@export var look_around_interval: float = 4.0

@onready var sprite := get_node(sprite_path) as AnimatedPaper3D
@onready var state := get_node(state_path) as StateContainer

var _t := 0.0


func _process(delta):
	_t += delta

	var mode = state.dict.get_value("mode", "default")
	var animation = ""

	if mode == "look_around" and _t >= look_around_interval:
		_t = 0.0
		animation = look_around_anims[randi() % look_around_anims.size()]
	elif mode == "default":
		var talking = state.flags.has("$talk")
		animation = default_talk_anim if talking else default_idle_anim

	if animation != "":
		sprite.animation = animation
