extends Node2D

#signal videoke_exited

@onready var karaoke = $Karaoke


func _on_exit():
	Story.emit("videoke_exited")


func _input(event):
	if (event.is_action_pressed("k_interact") or event.is_action_pressed("c_cancel")):
		if karaoke.can_exit() and is_visible_in_tree():
			get_viewport().set_input_as_handled()
			_on_exit()
