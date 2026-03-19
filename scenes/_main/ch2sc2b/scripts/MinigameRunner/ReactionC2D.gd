extends TextureRect

@onready var tween = Threen.new()

enum PanDirection { left, right }
const offset = 60
const duration = 3

func _ready():
	add_child(tween)


func show_c2d(tex: Texture, pan_direction):
	texture = tex
	visible = true

	match pan_direction:
		PanDirection.left:
			position = Vector2.ZERO
			tween.interpolate_property(
				self,
				"position",
				position,
				Vector2(-offset, 0),
				duration,
				Threen.TRANS_LINEAR,
				Threen.EASE_IN
			)
		PanDirection.right:
			position = Vector2(-offset, 0)
			tween.interpolate_property(
				self,
				"position",
				position,
				Vector2.ZERO,
				duration,
				Threen.TRANS_LINEAR,
				Threen.EASE_IN
			)

	tween.start()


func hide_c2d():
	visible = false
