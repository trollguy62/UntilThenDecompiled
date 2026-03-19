@tool
extends Node3D

@export var on = false

@export var oscillating = false
@export var oscillation_angle = 30.0 # degrees
@export var oscillation_speed = 1.0

@export var blade: Node3D
@export var blade_rpm = 60.0

var _activation := 0.0
var _oscillation_t := 0.0


# Prevent unwanted changes by making changing properties the same on save
func _notification(what: int):
	if not Engine.is_editor_hint():
		return

	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		rotation = Vector3.ZERO

		if blade != null:
			blade.rotation = Vector3.ZERO


func _process(delta):
	_activation = lerp(_activation, 1.0 if on else 0.0, 0.04)
	var dt = delta * _activation

	if oscillating:
		_oscillation_t += dt

	rotation.y = sin(_oscillation_t * oscillation_speed) * deg_to_rad(oscillation_angle)

	if blade != null:
		blade.rotate_z(blade_rpm / 60.0 * 2.0 * PI * dt)
