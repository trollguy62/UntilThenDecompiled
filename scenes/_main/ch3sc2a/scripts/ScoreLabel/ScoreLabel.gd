extends Label

@export var state_container_alias := ""
@export var dict_score_key := ""
@export var mult_modulate := Color(1, 1, 1, 0.7)

@onready var tween = Threen.new()

@onready var state = Utils.get_state_container_of(state_container_alias) as StateContainer

var _score := 0


func _ready():
	add_child(tween)
	state.changed.connect(_state_changed)
	_state_changed()

	modulate = mult_modulate


func _state_changed():
	var new_score = int(state.dict.get_value(dict_score_key, 0))

	if _score != new_score:
		_score = new_score
		_update_score()


func _update_score():
	text = str(_score)

	tween.stop_all()
	tween.interpolate_property(self, "modulate", Color.GREEN * mult_modulate, mult_modulate, 1.5)
	tween.start()
