extends PathFollow3D

const PathGrounder = preload("res://components/PathGrounder.gd")

@export var path_grounder: Node
@export_range(0.0, 1.0) var lerp_weight = 0.5

@onready var path: Path3D = get_parent()
@onready var curve: Curve3D = get_parent().curve
@onready var camera = get_child(0) as Camera3D

var _target_progress_ratio := 0.0


func _ready():
	assert(get_child_count() == 1)
	assert(path_grounder is PathGrounder)


func _physics_process(_delta):
	_target_progress_ratio = path_grounder.path_unit_offset
	progress_ratio = lerp(progress_ratio, _target_progress_ratio, lerp_weight)
