@tool
extends Node3D

@export var on = true:
	set = set_on

@onready var _motor = $Neck/Motor
@onready var _blade = $Neck/Motor/Blade


func _ready():
	self.on = on


func set_on(value):
	on = value

	if is_inside_tree():
		_motor.speed = 1 if on else 0
		_blade.speed = 23 if on else 0
