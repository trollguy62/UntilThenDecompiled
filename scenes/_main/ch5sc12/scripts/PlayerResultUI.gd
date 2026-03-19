extends Control

@onready var rank = $HBoxContainer/Rank
@onready var player_name = $HBoxContainer/Name
@onready var time = $HBoxContainer/Time


func set_rank(_rank):
	_rank = str(_rank)
	match _rank:
		"1":
			_rank += "st"
		"2":
			_rank += "nd"
		"3":
			_rank += "rd"
		_:
			_rank += "th"

	rank.text = str(_rank)


func set_name(_player_name):
	player_name.text = _player_name


func set_time(_time_finished):
	time.text = str(_time_finished)


func set_main_player(is_mainplayer):
	if is_mainplayer:
		player_name.add_theme_color_override("font_color", Color(0.333618, 1, 0.195312))
		time.add_theme_color_override("font_color", Color(0.333618, 1, 0.195312))
	else:
		player_name.add_theme_color_override("font_color", Color(1, 1, 1))
		time.add_theme_color_override("font_color", Color(1, 1, 1))
