@tool
extends Node3D

@export var extent := 50.0
@export_range(-1.0, 1.0) var factor := 0.0

@onready var _orig_pos_x := position.x


func _process(_delta):
	position.x = _orig_pos_x + factor * extent
