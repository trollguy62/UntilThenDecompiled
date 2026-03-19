extends Light2D


func _process(delta):
	visible = not get_tree().paused
