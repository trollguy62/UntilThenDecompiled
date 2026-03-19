extends Node
class_name  AnimalMovement

@export var speed : float = 1
@export var idle_animations: Array[String]
@export var move_animations: Array[String]

@onready var sprite = $Sprite
@onready var path_follow : PathFollow3D

func _ready():
	if (get_parent() is PathFollow3D):
		path_follow = get_parent()

func _process(delta):
	for anim in move_animations:
		if anim == sprite.animation:
			path_follow.progress += delta * speed

func set_move_animation():
	Utils.randomize()
	var random_anim = randi_range(0,move_animations.size()-1)
	sprite.animation = move_animations[random_anim]

func set_idle_animation():
	Utils.randomize()
	var random_anim = randi_range(0,idle_animations.size()-1)
	sprite.animation = idle_animations[random_anim]
