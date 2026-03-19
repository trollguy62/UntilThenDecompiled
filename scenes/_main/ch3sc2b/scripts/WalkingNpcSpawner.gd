extends Node3D

@export var enabled = true:
	set(v):
		if not is_inside_tree():
			await ready
		enabled = v
		if enabled:
			spawn_timer.start(_get_random_spawn_delay())
		else:
			spawn_timer.stop()

@export var walking_npcs: Array[Resource] = []
@export var walk_anim: String = "walk"
@export var speed = 1.0 #m/s
@export var min_spawn_delay: float = 11
@export var max_spawn_delay: float = 42
@export var reverse_flip: bool = false
@onready var spawn_timer: Timer = $Timer
@onready var planes = $Planes

var _spawnable_npc_indices = []


func _enter_tree():
	Story.add_command_handler(_run_command)

func _exit_tree():
	Story.remove_command_handler(_run_command)

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	for i in walking_npcs.size():
		_spawnable_npc_indices.append(i)

func spawn_new_random_npc():
	#print("Spawning new npc")
	if walking_npcs.is_empty():
		printerr("WalkingNPCs contains no instantiable NPCs!")
		return
	if _spawnable_npc_indices.is_empty():
		printerr("There are no spawnable NPCs left")
		return

	#FIXME: due to a AnimatedPaper3D quirk, multiple instances of the same npc share state
	##leading to flipped sprites when they shouldnt
	##This tries to work around that by keeping track of which npc is already spawned
	##and guaranteeing there can only be one
	var npc_index = _spawnable_npc_indices[randi() % _spawnable_npc_indices.size()]
	_spawnable_npc_indices.erase(npc_index)

	var npc_scene = walking_npcs[npc_index]

	var npc = npc_scene.instantiate()
	add_child(npc)

	var target_plane = planes.get_child(randi() % planes.get_child_count())
	#print(npc.name, "@", target_plane.name)

	var waypoints = [target_plane.get_child(0).global_position, target_plane.get_child(1).global_position]
	waypoints.shuffle()

	var dist = waypoints[0].x - waypoints[1].x
	npc.global_position =  waypoints[0]

	#FIXME: hack, breaks encap
	var npc_sprite = npc.get_node("Sprite")
	npc_sprite.play(walk_anim)
	npc_sprite.flip_h = dist >= 0 if reverse_flip else dist < 0
	#

	var tween = get_tree().create_tween()
	var duration = abs(dist) / speed
	#adds variation to walk speed
	duration *= randf_range(1.0, 1.66)

	tween.tween_property(npc, "global_position", waypoints[1], duration)
	tween.finished.connect(_on_npc_waypoint_reached.bind(npc, npc_index))

func _on_spawn_timer_timeout():
	spawn_timer.start(_get_random_spawn_delay())
	spawn_new_random_npc()

func _on_npc_waypoint_reached(npc, idx):
	npc.queue_free()
	#re-add the idx so we can spawn it again
	_spawnable_npc_indices.append(idx)

func _get_random_spawn_delay() -> float:
	return randf_range(min_spawn_delay, max_spawn_delay)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"walking_npc":
			if params[0] == "start":
				enabled = true
			if params[0] == "stop":
				enabled = false
		_:
			return Constants.CMD_RETURN_NONE

	return null
