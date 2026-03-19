extends Node

#0: intro
#1: A
#2: B & C
#3: C
#4: End

enum Marker { INTRO, A_LOOP, B_AND_C_LOOP, C_LOOP, END }

@export var marker: Marker = Marker.INTRO
@export var disabled = false

var _container

@onready var music_node_ref = $Sc10b.get_ref()


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _skit_start(skit_container):
	_container = skit_container
	if disabled:
		music_node_ref.stop()
		return

	music_node_ref.set_parameter("Marker", marker)
	#music_node_ref.stopped.connect(_on_music_stopped)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if params.size() > 0 and str(params[0]) != music_node_ref.name:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_marker":
			var param_value = params[1]
			marker = param_value
			music_node_ref.set_parameter("Marker", param_value)
			print("transitioning to: ", param_value)
		_:
			return Constants.CMD_RETURN_NONE

	return null


func _on_music_stopped():
	_container.emit_local("music_stopped")
