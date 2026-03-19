extends VBoxContainer

const log_entry = preload("res://scenes/_main/ch6sc1a/RpgMinigame/RpgLogEntry.tscn")


func _ready():
	clear()


func push(text: String, params: Dictionary = {}):
	var new_log = log_entry.instantiate()
	new_log.text = tr(text).format(params)
	add_child(new_log)


func pop():
	get_children()[get_child_count() - 1].queue_free()


func clear():
	for rpg_log in get_children():
		rpg_log.queue_free()
