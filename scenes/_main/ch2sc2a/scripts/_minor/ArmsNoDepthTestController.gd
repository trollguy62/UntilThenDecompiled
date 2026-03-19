extends Node

@onready var arms = get_parent()
@onready var sprite = arms.get_parent()


func _process(delta: float):
	var frame = sprite.frame
	var animation = sprite.animation

	if not arms.has_animation(animation):
		return

	var frame_count = arms.texture_frames.get_frame_count(animation)

	arms.visible = arms.has_animation(animation) and frame < frame_count

	if arms.visible:
		arms.playing = false
		arms.frame = frame
		arms.animation = animation
