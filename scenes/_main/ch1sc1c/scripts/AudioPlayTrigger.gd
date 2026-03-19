extends AudioStreamPlayer


func _ready():
	get_parent().triggered.connect(play)
