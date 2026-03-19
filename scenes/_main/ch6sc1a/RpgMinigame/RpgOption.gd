extends Control


func fade():
	$AnimationPlayer.play("fade")


func reset():
	$AnimationPlayer.play("RESET")
