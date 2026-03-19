extends Node

@export var enabled := true
@export_range(0, 1) var damping: float = 0.4

@onready var parent = get_parent()

var _ray_casts := []


func _ready():
	for sibling in get_parent().get_children():
		if sibling is RayCast3D:
			_ray_casts.append(sibling)


func _process(delta):
	if not enabled:
		return

	var y = parent.global_transform.origin.y
	var target_y = -INF
	_pre_physics_process(delta)

	for ray_cast in _ray_casts:
		if ray_cast.is_colliding():
			var cy = ray_cast.get_collision_point().y
			target_y = max(target_y, cy)

	if target_y != -INF:
		var ly = lerp(y, target_y, damping)
		parent.global_transform.origin.y = ly

	_post_physics_process(delta)


func _pre_physics_process(delta):
	pass


func _post_physics_process(delta):
	pass
