extends "InputController.gd"


func is_just_pressed():
	return Input.is_action_just_pressed("interact")
