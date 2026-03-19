extends CharacterBody3D

var force = 0.05
var acceleration = 0
var max_speed = 1


func _ready():
	set_physics_process(false)


func steer():
	set_physics_process(true)


func _physics_process(delta):
	if acceleration < max_speed:
		acceleration += delta * force

	position.x += acceleration
