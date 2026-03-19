extends Area2D

signal finished


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(player: CharacterBody2D):
	finished.emit()
