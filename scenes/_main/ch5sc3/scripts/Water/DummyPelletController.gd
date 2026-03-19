extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	parent.visible = true
	parent.freeze = false

#	await get_tree().create_timer(5.0)
#
#	parent.visible = false
#	parent.freeze = true

func _physics_process(delta):
	if abs(get_parent().global_transform.origin.y) > 50.0:
		get_parent().visible = false
		get_parent().freeze = true
