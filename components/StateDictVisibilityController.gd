extends Node

@export var state_container_alias := ""
@export var invert := false
@export var reduce_or := false
@export var dict_values := {}
@export var defer_update_on_ready := false

@onready var state := Utils.get_state_container_of(state_container_alias) as StateContainer
@onready var parent := get_parent()


func _ready():
	state.changed.connect(_on_state_changed)

	if defer_update_on_ready:
		await get_tree().process_frame
	_update_visibility()


func _on_state_changed():
	_update_visibility()


func _update_visibility():
	parent.visible = _is_visible()


func _is_visible() -> bool:
	var visible = false

	for key in dict_values.keys():
		var value = dict_values[key]
		var state_value = state.dict.get_value(key)
		var is_match = _is_equivalent(value, state_value)

		if reduce_or:
			if is_match:
				visible = true
				break
		else:
			if is_match:
				visible = true
			else:
				visible = false
				break

	return visible != invert


func _is_equivalent(value, state_value) -> bool:
	if value is Array:
		return value.has(state_value)
	else:
		var has_same_type = typeof(value) == typeof(state_value)
		return has_same_type and value == state_value
