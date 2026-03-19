extends CanvasLayer

signal time_finish

@onready var time_left = $UI/LabelTimeLeft
@onready var timer_time_left = $TimerTimeLeft

@onready var ui = $UI
@onready var parent = get_parent()

var seconds: int : set = _set_game_time
var ui_visible := false

var _seconds: int
var _alert_time_enabled := false
var _alert_time_t := 0.0


func _ready():
	timer_time_left.timeout.connect(_on_time_left_timedout)


func _process(delta):
	visible = parent.is_visible_in_tree()
	ui.visible = ui_visible

	if _alert_time_enabled:
		_alert_time_t += delta * 4.0
		time_left.scale = Vector2.ONE * Utils.sin_bounded(_alert_time_t, 1, 1.2)
		time_left.modulate = lerp(Color.WHITE, Color.RED, Utils.sin_bounded(_alert_time_t, 0, 1))
	else:
		time_left.scale = Vector2.ONE
		time_left.modulate = Color.WHITE


func _set_game_time(value):
	_seconds = value
	time_left.text = _get_remaining_time_str(_seconds)


func _on_time_left_timedout():
	_seconds -= 1
	time_left.text = _get_remaining_time_str(_seconds)

	if _seconds <= 20:
		_alert_time_enabled = true

	if _seconds < 1:
		time_finish.emit()
		timer_time_left.stop()
		_alert_time_enabled = false


func _get_remaining_time_str(seconds) -> String:
	var minute = seconds / 60
	var sec = fmod(seconds, 60)

	if sec < 10:
		sec = "0" + str(sec)

	var time_in_str = str(minute) + ":" + str(sec)
	return time_in_str
