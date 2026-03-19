extends Node3D

@export var sprite_path: NodePath
@export var animation_map: Array[Array] = [] # Array[Array[String]]

@onready var sprite = get_node(sprite_path)


func _ready():
	assert(animation_map.size() == get_child_count() - 1)


func _process(_delta):
	var anim = sprite.animation
	var idx = _get_idx(anim)

	for i in range(get_child_count()):
		var child = get_child(i)
		child.visible = idx == i


func _get_idx(animation: String) -> int:
	for i in range(animation_map.size()):
		for s in animation_map[i]:
			if animation == s or animation.match(s):
				return i

	return get_child_count() - 1
