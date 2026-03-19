extends Button

signal change_active_button(button)

@onready var tween = Threen.new()

@export var normal_color: Color
@export var hover_color: Color
@export var active_color: Color

var active := false:
	set = _set_active

var _is_ready := false


func _ready():
	add_child(tween)

	modulate = normal_color
	set("theme_override_colors/font_color_hover", hover_color)

	_is_ready = true


func _set_active(value):
	if _is_ready:
		active = value
		var color = active_color if active else normal_color

		tween.interpolate_property(
			self, "modulate", modulate, color, 0.5, Threen.TRANS_CUBIC, Threen.EASE_OUT
		)
		tween.start()
