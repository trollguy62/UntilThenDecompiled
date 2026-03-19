extends PanelContainer

@export_range(0.0, 16.0) var pulse_duration = 1.0
@export_range(0.0, 16.0) var pulse_delay = 0.5
@export var pulse_rect_scale := Vector2(1.1, 1.25)

@onready var tween = Threen.new()

var pulsing := false:
	set = _set_pulsing,
	get = _get_pulsing


func _ready():
	visible = false
	self.pulsing = pulsing

	add_child(tween)
	tween.tween_all_completed.connect(_on_tween_all_completed)


func _process(_delta):
	pivot_offset = size / 2


func _set_pulsing(value):
	pulsing = value
	if not tween:
		return

	if pulsing:
		visible = true
		if not tween.is_active():
			_pulse()


func _get_pulsing():
	return pulsing


func _on_tween_all_completed():
	if pulsing:
		await Utils.wait(pulse_delay)
		_pulse()
	else:
		modulate = Color.TRANSPARENT


func _pulse():
	var scale = [Vector2.ONE, pulse_rect_scale]
	var c = [Color.WHITE, Color.TRANSPARENT]

	tween.interpolate_property(self, "modulate", c[0], c[1], pulse_duration)
	tween.interpolate_property(self, "scale", scale[0], scale[1], pulse_duration)
	tween.start()


func pulse_once():
	if not pulsing:
		_pulse()
