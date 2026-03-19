extends PathFollow3D

@export var pivot: Node

@onready var path: Path3D  = get_parent()


func _process(delta):
	var closest_offset = path.curve.get_closest_offset(pivot.global_transform.origin)
	progress = closest_offset
