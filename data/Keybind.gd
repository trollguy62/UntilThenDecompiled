extends Resource

@export var action: String = ""
@export var name: String = ""
@export var group: String = ""
@export var key: InputEvent
@export var c_key: InputEvent

func _init(
	_action: String = "",
	_name: String = "",
	_group: String = "",
	_key: InputEvent = null,
	_c_key: InputEvent = null
):
	action = _action
	name = _name
	group = _group
	key = _key
	c_key = _c_key
