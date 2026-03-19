extends Control

@export var player_name: String = "ilovesuckinglemons"
@export var flip_align: bool = false

@onready var hp_rect = $HP/HPValue
@onready var hp_label = $HP/HPText
var hp = 100:
	set(v):
		hp = v
		hp_rect.size.x = max(0.0, _bar_max_length * (hp / float(max_hp)))
		hp_label.text = str(hp) + "/" + str(max_hp)

var max_hp = 100:
	set(v):
		max_hp = v
		hp_rect.size.x = max(0.0, _bar_max_length * (hp / float(max_hp)))
		hp_label.text = str(hp) + "/" + str(max_hp)

var _bar_max_length: float

func set_hp(_hp):
	if _hp < 0:
		_hp = 0
	hp = _hp

func _ready():
	_bar_max_length = hp_rect.size.x
	$HBoxContainer/Name.text = player_name
	hp_label.text = str(hp) + "/" + str(max_hp)
	if flip_align:
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
