extends Node

@onready var sprite = get_parent()
@onready var mark_state = Utils.get_state_container_of("MarkBorja") as StateContainer
@onready var cathy_state = Utils.get_state_container_of("CathyPortillo") as StateContainer


func _ready():
	mark_state.changed.connect(_update_animation)
	cathy_state.changed.connect(_update_animation)


func _update_animation():
	var animation = get_animation()
	if sprite.has_animation(animation):
		sprite.animation = animation


func get_animation() -> String:
	if mark_state.flags.has("laugh") or cathy_state.flags.has("laugh"):
		return "both_laugh"
	elif cathy_state.flags.has("lean"):
		return "cathy_lean"
	elif cathy_state.flags.has("holdarm_trans"):
		return "cathy_holdarm_trans"
	elif mark_state.flags.has("$talk"):
		return "cathy_holdarm_mark"
	elif cathy_state.flags.has("$talk"):
		return "cathy_holdarm_cathy"
	else:
		return "cathy_holdarm"
