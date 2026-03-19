extends Node2D

signal mouse_enter(balloon)
signal mouse_exit

@export var score := 1

@onready var collider = $Area2D/CollisionShape2D
@onready var sprite = $Sprite
@onready var anim_sprite = $AnimatedSprite

var is_popped = false


func pop():
	collider.set_deferred("disabled", true)
	sprite.visible = false
	anim_sprite.visible = true
	anim_sprite.play("default")
	is_popped = true
	await Utils.wait(0.1)
	anim_sprite.visible = false


func restore():
	collider.set_deferred("disabled", false)
	sprite.visible = true
	anim_sprite.frame = 0
	anim_sprite.playing = false
	anim_sprite.visible = true
	is_popped = false
