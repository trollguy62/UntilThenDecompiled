extends TextureRect

const ZOOM_SCALE = 2
const ZOOMING_CURSOR = preload("res://assets/ui/cursors/animated_hand_pinch.tres")
const ZOOMING_CURSOR_REVERSED = preload("res://assets/ui/cursors/animated_hand_pinch_reversed.tres")
const CONTROLLER_PAN_FACTOR = 2.5

var _zoomed = false
var _pressed = false

@onready var tween = Threen.new()


func _ready():
	add_child(tween)
	tween.tween_started.connect(_on_zoom_toggled)
	tween.tween_completed.connect(_on_zoom_completed)

func _process(delta):
	if _zoomed:
		var input_vector = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
		_pan(CONTROLLER_PAN_FACTOR * input_vector)

func _unhandled_input(ev):
	if ev is InputEventJoypadMotion:
		if ev.axis == JOY_AXIS_RIGHT_Y:
			var e = InputEventMouseButton.new()
			e.position = get_viewport().get_mouse_position()
			e.position *= (
				get_viewport().size.y
				/ float(ProjectSettings.get_setting("display/window/size/viewport_height"))
			)

			if ev.axis_value < -0.75 and not (_zoomed or _pressed):
				_toggle_zoom()
			if ev.axis_value > 0.75 and _zoomed:
				_toggle_zoom()

func _gui_input(ev):
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		_pressed = ev.pressed
		if ev.double_click and texture != null:
			_toggle_zoom(ev.position)
	elif _zoomed and _pressed:
		if ev is InputEventMouseMotion:
			_pan(ev.relative)

func _pan(vector):
	if texture == null:
		return

	position += vector * ZOOM_SCALE
	var size_y_pixels = size.x / texture.get_size().aspect()
	position.x = clamp(position.x, pivot_offset.x - size.x, pivot_offset.x)

	var max_y_offset = max(
		pivot_offset.y - (size.y - size_y_pixels) / 2.0 * ZOOM_SCALE,
		pivot_offset.y - size_y_pixels
	)
	var min_y_offset = min(
		pivot_offset.y - (size.y - size_y_pixels) / 2.0 * ZOOM_SCALE,
		pivot_offset.y - size_y_pixels
	)

	position.y = clamp(position.y, min_y_offset, max_y_offset)

func _toggle_zoom(pivot_pos = Vector2(size / 2.0)):
	_zoomed = not _zoomed
	var to_scale = Vector2.ONE

	if _zoomed:
		pivot_offset = pivot_pos
		to_scale *= ZOOM_SCALE

	tween.interpolate_property(
		self, "scale", scale, to_scale, 0.2, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.interpolate_property(
		self, "position", position, Vector2.ZERO, 0.2, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.start()


func _on_zoom_toggled(o, k):
	var cursor = ZOOMING_CURSOR_REVERSED if _zoomed else ZOOMING_CURSOR


func _on_zoom_completed(o, k):
	var cursor = ZOOMING_CURSOR_REVERSED if _zoomed else ZOOMING_CURSOR
