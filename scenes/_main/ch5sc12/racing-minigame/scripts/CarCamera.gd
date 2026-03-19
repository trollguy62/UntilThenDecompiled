extends Camera3D

const MAX_LERP_INCR = 0.1

@export var lerp_speed = 3.0
@export var target_path : NodePath
@export var offset : Vector3 = Vector3.ZERO

var target = null


func _ready():
	if target_path:
		target = get_node(target_path)


func _physics_process(delta):
	if !target:
		return
	var target_pos = target.car_mesh.global_transform.translated_local(offset)
	var lerp_incr = clamp(lerp_speed * delta, -MAX_LERP_INCR, MAX_LERP_INCR)
	global_transform = global_transform.interpolate_with(target_pos, lerp_incr)
	look_at(target.car_mesh.global_transform.origin,Vector3(0,1,0))
