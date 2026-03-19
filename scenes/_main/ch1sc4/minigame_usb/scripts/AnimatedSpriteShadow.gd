extends Sprite2D

@onready var parent = get_parent() as AnimatedSprite2D


func _process(delta):
	texture = parent.sprite_frames.get_frame_texture(parent.animation, parent.frame)
