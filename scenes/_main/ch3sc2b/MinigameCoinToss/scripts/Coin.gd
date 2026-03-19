extends Sprite2D

@onready var tween = Threen.new()

var fade_out_duration: float


func _ready():
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color.BLACK, Color.WHITE, 0.25)
	tween.interpolate_property(self, "scale", Vector2.ONE * 2 * 3, Vector2.ONE * 2, 0.25)
	tween.start()
	await tween.tween_all_completed

	await Utils.wait(4)

	fade_out()


func fade_out():
	tween.interpolate_property(
		self,
		"modulate",
		modulate,
		Color.TRANSPARENT,
		fade_out_duration,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN_OUT
	)
	tween.start()
	await tween.tween_all_completed
	queue_free()


func get_test_global_positions() -> Array:
	var positions = []

	for child in get_children():
		if child is Marker2D:
			positions.append(child.global_position)

	return positions
