extends PanelContainer

signal pressed

@onready var tween = Threen.new()
@onready var button = $Button
@onready var hbox = $HBox
@onready var choice_text_field = $"../Main/ChoiceTextField"

var show := false:
	set(value):
		if show != value:
			show = value
			_slide(value)
			# Prevents button from taking focus while hidden
			button.focus_mode = Control.FOCUS_ALL if show else Control.FOCUS_NONE


	get:
		return show

var _offset_top = 0


func _ready():
	add_child(tween)
	visible = false
	_slide(false, 0)
	focus_entered.connect(button.grab_focus)
	button.pressed.connect(func(): pressed.emit())


func _process(delta):
	position.x = 0
	global_position.y = choice_text_field.global_position.y - hbox.size.y - 16 + _offset_top
	button.custom_minimum_size = hbox.size


func _slide(into: bool, duration = 0.2):
	var top = [24, 0]
	var c = [Color.TRANSPARENT, Color.WHITE]

	if into:
		visible = true
	else:
		top.reverse()
		c.reverse()

	tween.stop_all()
	tween.interpolate_property(
		self, "_offset_top", top[0], top[1], duration, Threen.TRANS_QUAD, Threen.EASE_OUT
	)
	tween.interpolate_property(self, "modulate", c[0], c[1], duration)
	tween.start()

	if not into:
		await tween.tween_completed
		visible = false
