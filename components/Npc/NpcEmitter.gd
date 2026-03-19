extends Node

const NpcPathFollow: PackedScene = preload("res://components/Npc/NpcPathFollow.tscn")

@export var amount := 100
@export var paths: Array[NodePath] = []
@export var min_global_offsets: Array[Vector3] = []
@export var max_global_offsets: Array[Vector3] = []
@export var interval_min := 3.0
@export var interval_max := 6.0
@export var scale_mult := 1.0
@export var free_on_path_end := false
@export var loop_on_path_end := true
@export var bidirectional := false

@onready var timer = $Timer

var _npcs := []
var _idx := 0


func _ready():
	timer.timeout.connect(_launch_next_npc)
	timer.start(randf_range(interval_min, interval_max))

	for i in range(amount):
		_add_npc()
		if (i + 1) % 5 == 0:
			await get_tree().process_frame


func _add_npc():
	var npc = NpcPathFollow.instantiate()
	var idx = randi() % paths.size()

	var path = get_node(paths[idx])
	var min_global_offset = Utils.array_get(min_global_offsets, idx, Vector3())
	var max_global_offset = Utils.array_get(max_global_offsets, idx, Vector3())
	var global_offset = Vector3(
		randf_range(min_global_offset.x, max_global_offset.x),
		randf_range(min_global_offset.y, max_global_offset.y),
		randf_range(min_global_offset.z, max_global_offset.z)
	)

	npc.path = path
	npc.global_offset = global_offset
	npc.free_on_path_end = free_on_path_end
	npc.loop_on_path_end = loop_on_path_end
	npc.scale *= scale_mult * randf_range(0.95, 1.02)

	_npcs.append(npc)
	add_child(npc)


func _launch_next_npc():
	if _idx < _npcs.size():
		var offset_speed = randf_range(0.6, 0.7)
		if bidirectional:
			offset_speed *= _rand_sgn()

		_npcs[_idx].offset_speed = offset_speed
		_idx += 1

	timer.start(randf_range(interval_min, interval_max))


func _rand_sgn() -> float:
	return 1.0 if randi() % 2 == 0 else -1.0
