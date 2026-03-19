extends AudioStreamPlayer3D


func _ready():
	get_parent().triggered.connect(play)
