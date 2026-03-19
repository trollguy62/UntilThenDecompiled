#KStateMachine minimal impl
extends Node

const KState = preload("./KState.gd")

@export var target_node: NodePath = ""
@export var target_initial_state: NodePath = ""
var target
var states: Dictionary = {}
var current_state: KState
var initial_state: KState


func _ready():
	if target_node.is_empty():
		target = get_parent()
	else:
		target = get_node(target_node)

	await get_parent().ready

	assert(target)
	states = get_all_states(self)
	initialize()


######################################


func _process(delta):
	current_state.update(delta)


func _physics_process(delta):
	current_state.physics_update(delta)


func _input(event):
	current_state.input(event)


func _unhandled_input(event):
	current_state.unhandled_input(event)


func _unhandled_key_input(event):
	current_state.unhandled_key_input(event)


######################################


func get_all_states(node) -> Dictionary:
	for nd in node.get_children():
		if "get_custom_class" in nd and nd.get_custom_class() == "KState":
			states[nd.name] = nd

	return states


func transition_to(next_state):
	assert(next_state)
	if !next_state:
		return

	var state_name
	if !current_state:
		current_state = KState.new()
		state_name = "NONE"
	else:
		state_name = current_state.name

	print("State: ", state_name, "->", next_state.name)

	current_state.on_exited()
	next_state.on_entered()
	current_state = next_state


func initialize():
	for s in states.values():
		s.ksm = self
		s.target = target

	initial_state = get_node(target_initial_state)

	assert(initial_state)
	if initial_state:
		transition_to(initial_state)
		current_state = initial_state


## USED FOR DEBUGGING ##
func force_exit_state():
	current_state.on_exited()


func reset():
	call_deferred("initialize")


func force_reload():
	current_state.on_entered()
