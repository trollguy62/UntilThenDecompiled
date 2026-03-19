@tool
extends Paper3D

@onready var parent = get_parent() as AnimatedPaper3D


func _process(delta):
	self.texture = parent.current_texture_frame
