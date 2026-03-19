extends HBoxContainer

const HOVER_COLOR = Color(1.0, 1.0, 1.0, 0.8) #BLACK, 20% Alpha

@export_multiline var text = "Sample text"
@export var align_right = false

@export var font: Font
@export var font_color: Color = Color.BLACK
@export var background_style: StyleBox = StyleBoxEmpty.new()
@export var link_url: String = "":
	set(v):
		link_url = v
#		if link_url != "":
#			focus_mode = Control.FOCUS_ALL

@export var padding_left: int = 16
@export var padding_right: int = 16
@export var padding_top: int = 12
@export var padding_bottom: int = 12

@onready var label: Label = $LabelContainer/Label
@onready var label_container: HBoxContainer = $LabelContainer


func _ready():
	label.draw.connect(_update_label_alignment)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	focus_mode = Control.FOCUS_ALL
	label.pressed.connect(_on_pressed)
	label.text = text

	if align_right:
		move_child(label_container, 1)
		_update_label_alignment()

	label.set("theme_override_fonts/font", font)
	label.set("theme_override_colors/font_color", font_color)
	label.set_bg_style(background_style)

	var stylebox: StyleBox = label.get("theme_override_styles/normal")
	stylebox.content_margin_left = padding_left
	stylebox.content_margin_right = padding_right
	stylebox.content_margin_top = padding_top
	stylebox.content_margin_bottom = padding_bottom

func _on_focus_entered():
	self.modulate = HOVER_COLOR

func _on_focus_exited():
	self.modulate = Color.WHITE


func _update_label_alignment():
	if align_right and label.get_line_count() == 1:
		alignment = BoxContainer.ALIGNMENT_END
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		alignment = BoxContainer.ALIGNMENT_BEGIN


func _gui_input(event):
	if event.is_action("c_interact") and not event.pressed:
		_on_pressed()

func _on_pressed():
	if link_url == "":
		return

	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		navigator.push_named(link_url)
