@tool
extends Node3D

@export var speed = 1.0
@export var ocean_rel_speed = 0.5
@export var stage_incline_degs = 2.5
@export var offset_max = 10.0

@onready var background = $Background

@onready var ocean = $Ocean
@onready var ocean_mat = ocean.material_override as ShaderMaterial

@onready var stage = $Stage

var _offset := 0.0
var _ocean_offset := 0.0

func _ready():
	stage.global_transform.origin = Vector3.ZERO

func _process(delta):
	if not is_visible_in_tree():
		return

	var delta_offset = delta * speed
	_offset += delta_offset
	_ocean_offset += delta_offset * ocean_rel_speed

	while _offset >= offset_max:
		_offset -= offset_max

	stage.global_transform.origin = -stage.transform.basis.x * _offset
	stage.rotation_degrees = Vector3(0, 0, stage_incline_degs)

	ocean_mat.set_shader_parameter("vertex_offset", Vector3.RIGHT * _ocean_offset)
