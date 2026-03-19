extends Node2D

@export var move_vector := Vector2(0, -36)
@export var duration := 2.0

@onready var particles = $Particles
@onready var label = $Label

var text := ""

var _t := 0.0


func _ready():
	particles.emitting = true


func _process(delta):
	_t += delta

	if _t >= duration:
		queue_free()
	else:
		translate(move_vector * delta)
		label.modulate = Color(1, 1, 1, 1.0 - _t / duration)
		label.text = text
