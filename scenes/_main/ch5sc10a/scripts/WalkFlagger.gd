extends Node

const FLAG = "$walk"

@export var state_container: StateContainer
@export var walking := false:
	set(value):
		if not is_node_ready():
			return
		walking = value

		if walking:
			state_container.flags.add(FLAG)
		else:
			state_container.flags.remove(FLAG)
