extends PathFollow3D

@onready var tween = Threen.new()

@export var min_duration: float = 250
@export var max_duration: float = 300


func _ready():
	add_child(tween)
	var rng = RandomNumberGenerator.new()
	var duration = rng.randi_range(min_duration, max_duration)

	tween.interpolate_property(
		self, "unit_offset", 0, 1, duration, Threen.TRANS_LINEAR, Threen.EASE_IN_OUT
	)
	tween.start()

	await tween.tween_completed
	queue_free()
