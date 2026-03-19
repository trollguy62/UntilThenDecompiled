extends Node

@export var path: NodePath
@export var path_follow: NodePath
@export var player: NodePath

@onready var _camera_effects: CameraEffects = get_parent()
@onready var _path: Path3D = get_node(path)
@onready var _player := get_node(player)
@onready var _path_follow: PathFollow3D = get_node(path_follow)


func _process(_delta):
	_path_follow.progress = _path.curve.get_closest_offset(_player.global_transform.origin)
	var near_blur_dist = Utils.remap(0.35, 0.6, 1, 2, _path_follow.progress_ratio)
	_camera_effects.dof_blur_near_distance = near_blur_dist
