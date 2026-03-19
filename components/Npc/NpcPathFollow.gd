extends Node3D

@export var offset_speed := 0.0
@export var global_offset := Vector3()
@export var free_on_path_end := false
@export var loop_on_path_end := false

@onready var sprite = $NpcBasic
@onready var grounder = $PathGrounder

var path: Path3D


# TODO: Sucks that you have to really have to use $ here
# This'll be rehauled anyway
func _enter_tree():
	Utils.randomize()
	$NpcBasic.gender = Constants.MALE if randf() < 0.5 else Constants.FEMALE
	$NpcBasic.gen_seed = randi()
	$PathGrounder.path = path

	if loop_on_path_end:
		$PathGrounder.loop = true


func _process(delta):
	grounder.offset_speed = offset_speed
	grounder.global_offset = global_offset
	sprite.flip_h = offset_speed < 0

	if grounder.path_unit_offset == 1 and free_on_path_end:
		queue_free()
