@tool
extends Node3D

@export var rot_degs_per_sec := 10.0

@onready var tween := Threen.new()


func _ready():
	add_child(tween)


func _process(delta):
	rotate_z(deg_to_rad(rot_degs_per_sec) * delta)


func turn(degs: float, duration: float):
	tween.interpolate_property(
		self,
		"rotation_degrees:z",
		rotation_degrees.z,
		rotation_degrees.z + degs,
		duration,
		Threen.TRANS_QUAD,
		Threen.EASE_IN_OUT
	)
	tween.start()
	await tween.tween_completed


# Command handler
func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_run_command)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"ferris_wheel_set_rotation":
			rotation_degrees.z = params[0]
		"ferris_wheel_set_rotation_speed":
			rot_degs_per_sec = params[0]
		"ferris_wheel_turn":
			var fn = func(): await turn(params[0], params[1])
			if flags.has("wait"):
				await fn.call()
			else:
				fn.call()
		_:
			return Constants.CMD_RETURN_NONE

	return null
