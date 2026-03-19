extends "res://ui/modals/Modal.gd"

const PRESSED_POSITIVE = 2
const PRESSED_NEGATIVE = 1

@onready var title_label = $Background/VBox/Title
@onready var content_label = $Background/VBox/Content
@onready var button_container = $Background/VBox/Buttons
@onready var positive_btn = $Background/VBox/Buttons/PositiveBtn
@onready var negative_btn = $Background/VBox/Buttons/NegativeBtn

var title = ""
var content = ""
var positive_text = ""
var negative_text = ""
var color_accent = Color("#009485")


func _ready():
	positive_btn.pressed.connect(_on_positive_btn_pressed)
	negative_btn.pressed.connect(_on_negative_btn_pressed)

	title_label.text = title
	content_label.text = content
	positive_btn.text = positive_text.to_upper()
	negative_btn.text = negative_text.to_upper()

	title_label.visible = not title.is_empty()
	positive_btn.visible = not positive_text.is_empty()
	negative_btn.visible = not negative_text.is_empty()
	button_container.visible = positive_btn.visible or negative_btn.visible

	for btn in [positive_btn, negative_btn]:
		for prop in ["font_color", "font_color_hover", "font_color_pressed"]:
			btn.add_theme_color_override(prop, color_accent)


func _on_positive_btn_pressed():
	_return_value = PRESSED_POSITIVE
	dismiss()


func _on_negative_btn_pressed():
	_return_value = PRESSED_NEGATIVE
	dismiss()
