extends Resource
class_name AnimationTransition

@export var anim: String
@export var from_anim: String
@export var to_anim: String
@export var reversible := false


func matches(old_anim: String, new_anim: String):
	return (
		(old_anim == from_anim and new_anim == to_anim)
		or (reversible and old_anim == to_anim and new_anim == from_anim)
	)


func is_reversed(old_anim: String):
	return reversible and old_anim == to_anim
