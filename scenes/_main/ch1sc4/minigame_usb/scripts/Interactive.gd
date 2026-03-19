extends PanelContainer

signal pressed

const ANIM_DUR = 0.25
const SCALE_HIDDEN = Vector2.ONE * 0.7


@onready var tween = Threen.new()
@onready var icon_plug = $IconPlug
@onready var icon_flip = $IconFlip
@onready var button = $Button

var icon := "" : set = _set_icon, get = _get_icon


func _ready():
	add_child(tween)
	modulate = Color.TRANSPARENT
	scale = SCALE_HIDDEN
	self.icon = icon

	button.pressed.connect(_on_button_pressed)


func _set_icon(value):
	if icon == value:
		return
	icon = value
	if tween == null:
		return

	if icon in ["plug", "flip"]:
		icon_plug.visible = icon == "plug"
		icon_flip.visible = icon == "flip"
		_fade(true)
	else:
		_fade(false)


func _get_icon():
	return icon

func _on_button_pressed():
	pressed.emit()

func _fade(into: bool):
	var c = [modulate, Color.WHITE if into else Color.TRANSPARENT]
	var scale = [scale, Vector2.ONE if into else SCALE_HIDDEN]

	tween.stop_all()
	tween.interpolate_property(self, "modulate", c[0], c[1], ANIM_DUR)
	tween.interpolate_property(
		self,
		"scale",
		scale[0],
		scale[1],
		ANIM_DUR,
		Threen.TRANS_CUBIC,
		Threen.EASE_OUT if into else Threen.EASE_IN
	)
	tween.start()
