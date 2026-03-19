extends Node2D

@export var lifetime := 1.0
@export var actual_scale := 0.3

@onready var timer = Timer.new()


func _ready():
	assert(lifetime > 0)
	scale = Vector2.ONE * actual_scale

	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer.start(lifetime)


func _on_timeout():
	queue_free()
