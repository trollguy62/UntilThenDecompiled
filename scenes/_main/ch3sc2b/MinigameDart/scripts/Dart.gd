extends Sprite2D

@onready var tween = Threen.new()

var fade_out_duration: float


func _ready():
	add_child(tween)
	tween.interpolate_property(
		self, "scale", scale * 12, scale, 0.3, Threen.TRANS_CUBIC, Threen.EASE_OUT
	)
	tween.interpolate_property(self, "modulate", Color.BLACK, Color.WHITE, 0.3)
	tween.start()

	await tween.tween_completed
	await Utils.wait(2)
	await fade_out()


func fade_out():
	tween.interpolate_property(self, "modulate", modulate, Color.TRANSPARENT, fade_out_duration)
	tween.start()

	await tween.tween_completed
	queue_free()
