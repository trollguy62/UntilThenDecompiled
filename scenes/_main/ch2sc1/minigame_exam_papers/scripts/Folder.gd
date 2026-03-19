extends Area2D

signal change_set

@onready var tween = Threen.new()
@onready var sprite = $Sprite
@onready var original_pos = position


func _ready():
	add_child(tween)

func move_down():
	tween.interpolate_property(
		self,
		"position",
		position,
		Vector2(position.x, position.y + 700),
		2,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN_OUT
	)
	tween.start()

	await tween.tween_completed
	change_set.emit()
	_move_up()


func _move_up():
	if tween:
		tween.interpolate_property(
			self,
			"position",
			position,
			Vector2(original_pos.x, original_pos.y),
			2,
			Threen.TRANS_LINEAR,
			Threen.EASE_IN_OUT
		)
		tween.start()

		await tween.tween_completed
