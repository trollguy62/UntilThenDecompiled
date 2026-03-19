extends "res://ui/screens/Screen.gd"

@export var clamp_to_year: bool = true:
	set(v):
		if not is_inside_tree():
			await ready
		calendar.clamp_to_year = clamp_to_year
		clamp_to_year = v

@export var date: Dictionary = {"day": 1, "month": 1, "year": 1970}:
	set(v):
		if not is_inside_tree():
			await ready
		if v != null and "day" in v and "month" in v and "year" in v:
			date = v
			calendar.selected_date = date

@onready var anim_player = $AnimationPlayer
@onready var calendar = $VBoxContainer/ScrollContainer/MarginContainer/Calendar

func _ready():
	clamp_to_year = clamp_to_year
	date = date

func splash():
	anim_player.play("splash")

func _before_show():
	splash()
