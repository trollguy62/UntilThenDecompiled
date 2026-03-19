extends ColorRect

@onready var result_container = $VBoxContainer/PlayerResultContainer

var player_result = []


#
func _ready():
	for i in result_container.get_children():
		player_result.append(i)

	hide_all()


func display_result(result):
	for i in result.size():
		player_result[i].visible = true
		player_result[i].set_rank(i + 1)
		player_result[i].set_name(result[i].name)
		player_result[i].set_time(result[i].time)
		player_result[i].set_main_player(result[i].name == "Mark")


func hide_all():
	for result in player_result:
		result.visible = false
