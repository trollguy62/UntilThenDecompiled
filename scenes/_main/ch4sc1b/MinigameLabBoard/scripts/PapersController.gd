extends Node2D

@onready var sfx_paper_collision = $PaperCollision


func _ready():
	for body in get_children():
		if not body is RigidBody2D:
			continue
		body.body_entered.connect(_on_body_entered)


func _on_body_entered(_body):
	if not sfx_paper_collision.playing:
		sfx_paper_collision.play()
