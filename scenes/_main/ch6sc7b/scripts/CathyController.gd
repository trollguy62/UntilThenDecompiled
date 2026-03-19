extends Node

@export var look_at_spatial: NodePath

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var state = Utils.get_state_container_of(sprite.alias) as StateContainer
@onready var follower = $"../AnchorFollower"
@onready var sfx_footsteps = $Footsteps

@onready var look_at: Node3D = get_node(look_at_spatial)

var _last_pos := Vector3.ZERO


func _ready():
	follower.enabled = true


func _process(_delta):
	_process_flip_h()
	_process_state()


func _process_flip_h():
	var dz = look_at.global_transform.origin.z - parent.global_transform.origin.z
	sprite.flip_h = dz > 0


func _process_state():
	var current_pos = sprite.global_transform.origin

	if _last_pos.distance_to(current_pos) > Constants.EPSILON:
		state.flags.add("walk")
		if not sfx_footsteps.playing:
			sfx_footsteps.play()
	else:
		state.flags.remove("walk")
		sfx_footsteps.stop()

	_last_pos = current_pos
