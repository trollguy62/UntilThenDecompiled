extends Control

#warning-ignore:unused_signal
signal pressed

@export_multiline var text = "FlatLabelButton":
	set(value):
		text = value
		if label:
			label.text = value
	get:
		return text

@export var font: Font
@export var padding = Vector2(16, 4)
@export var text_color = Color.WHITE:
	set(v):
		if not is_inside_tree():
			await ready
		text_color = v
		label.add_theme_color_override("font_color", text_color)

@export var bg_color = Color.WHITE:
	set(v):
		if not is_inside_tree():
			await ready
		bg_color = v
		button.bg_color = bg_color

@onready var button = $FlatButton
@onready var label: Label = button.child


func _ready():
	button.pressed.connect(func(): pressed.emit())
	button.set_margins(padding.x, padding.y, padding.x, padding.y)
	button.bg_color = bg_color

	label.add_theme_font_override("font", font)
	label.add_theme_color_override("font_color", text_color)

	self.text = text
