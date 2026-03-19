extends TextureRect

signal cleared
signal intensity_changed

@export_range(0, 1, 0.001, "or_greater") var intensity = 0.1:
	set(v):
		intensity = clamp(v, 0.0, 1.0)
		material.set_shader_parameter("intensity", intensity)

		if intensity <= 0.000001:
			cleared.emit()

var focus_position = Vector2():
	set(v):
		focus_position = v
		material.set_shader_parameter("mouse_position", focus_position)

func _input(event):
	if event.is_action_pressed("choice_1"):
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "intensity", 0.0, 15.0)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_OUT)
