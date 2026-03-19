extends Node3D

const PathFollowScene = preload("res://components/Npc/NPCSpawner/prefabs/PathFollow.tscn")

@export var stop_spawn_when_near: bool = true
@export var npc_min_move_duration: float = 250
@export var npc_max_move_duration: float = 300
@export var npc_spawn_min_time_duration: float = 3
@export var npc_spawn_max_time_duration: float = 8

@export var npcs: Array[PackedScene]

@onready var paths = [$PathLeft, $PathMiddle, $PathRight]
@onready var timer = $TimerSpawner
@onready var visibility_notifier = $VisibilityNotifier

var _rng = RandomNumberGenerator.new()


func _ready():
	_rng.seed = randi()
	_spawn_random_npc()
	_set_timer_timeout()

	timer.timeout.connect(_spawn_random_npc)

	if stop_spawn_when_near:
		visibility_notifier.camera_entered.connect(_on_cam_entered)
		visibility_notifier.camera_exited.connect(_on_cam_exited)


func _spawn_random_npc():
	# add path follow
	var path_follow = PathFollowScene.instance()
	var path_index = _rng.randi_range(0, 2)
	paths[path_index].add_child(path_follow)

	# set path follow properties
	path_follow.min_duration = npc_min_move_duration
	path_follow.max_duration = npc_max_move_duration

	# spawn npc
	var npc_index = _rng.randf_range(0, npcs.size())
	path_follow.add_child(npcs[npc_index].instance())

	_set_timer_timeout()


func _set_timer_timeout():
	timer.wait_time = _rng.randf_range(npc_spawn_min_time_duration, npc_spawn_max_time_duration)


func stop():
	timer.stop()
	print("npc spawner stopped")


func resume():
	if timer.is_stopped():
		timer.start()
		print("npc spawner started")


func _on_cam_entered(cam):
	stop()


func _on_cam_exited(cam):
	resume()
