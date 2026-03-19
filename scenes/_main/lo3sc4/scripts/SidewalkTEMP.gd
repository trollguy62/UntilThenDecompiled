extends Node3D

const SIDEWALK_LENGTH = 1.97 * 19

@export var move_speed = 0.0

@onready var sidewalk = $Sidewalk
@onready var spawnables = $Spawnables

var spawned: Array[Node3D] = []


func _ready():
	sidewalk.position = Vector3(-SIDEWALK_LENGTH, 0, 0)


func _process(delta):
	var dx = move_speed * delta
	var new_x_pos = sidewalk.position.x + dx

	if new_x_pos >= 0:
		new_x_pos = -SIDEWALK_LENGTH + new_x_pos

	sidewalk.position.x = new_x_pos

	for node in spawned:
		node.position.x += dx


func spawn(node: Node):
	assert(node is Node3D)
	assert(node in spawnables.get_children())
	assert(not node in spawned)
	spawned.append(node)


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if not is_visible_in_tree():
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"sidewalk.set_move_speed":
			var speed = float(cmd.params[0])
			var duration = float(Utils.array_get(cmd.params, 1, 0))

			if duration == 0:
				move_speed = speed
			else:
				create_tween().tween_property(self, "move_speed", speed, duration)
		"sidewalk.spawn":
			var child_name = cmd.params[0] as String
			var spawnable = spawnables.get_node(child_name)
			spawn(spawnable)
		_:
			return Constants.CMD_RETURN_NONE

	return null
