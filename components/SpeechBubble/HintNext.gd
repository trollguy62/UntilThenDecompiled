extends TextureRect

const SHOW_HIDE_DUR = 0.2
const HINT_NEXT_COLOR = Color(1, 1, 1, 0.8)
const SHOW_OFFSET = Vector2(-16, 0)

@onready var tween = Threen.new()

var _is_clicked := false


func _ready():
	add_child(tween)


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_clicked = event.is_pressed()


func consume_click() -> bool:
	var c = _is_clicked
	_is_clicked = false
	return c


func show_hint(duration: float = SHOW_HIDE_DUR):
	var p1 = position
	var p0 = p1 + SHOW_OFFSET

	tween.interpolate_property(
		self, "position", p0, p1, duration, Threen.TRANS_QUAD, Threen.EASE_OUT
	)
	tween.interpolate_property(self, "modulate", modulate, HINT_NEXT_COLOR, duration)

	tween.start()
	await tween.tween_all_completed


func hide_hint(duration: float = SHOW_HIDE_DUR):
	tween.interpolate_property(self, "modulate", modulate, Color.TRANSPARENT, duration)
	tween.start()
	await tween.tween_all_completed
