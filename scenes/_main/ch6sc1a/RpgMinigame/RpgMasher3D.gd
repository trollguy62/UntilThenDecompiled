extends Node3D

signal mashed
signal hp_changed(new_hp)

@export var player_name = "ILoveSuckingLemons"
@export var max_hp = 100
@export var hp = 100:
	set(v):
		if v < 0:
			v = 0
		hp = v
@export var base_atk = 30
@export var base_def = 0
@export var variance: int = 3

var atk = 30:
	get:
		return base_atk + bonus_atk
var def = 0:
	get:
		return base_def + bonus_def

var bonus_atk = 0:
	get:
		return randi_range(-variance,variance)
var bonus_def = 0


func _unhandled_input(event):
	if event.is_action_pressed("c_interact") or event.is_action_pressed("interact"):
		emit_signal("mashed")


func take_damage(amount: int):
	self.hp -= amount# - self.def ##remove def for now
	emit_signal("hp_changed", hp)
