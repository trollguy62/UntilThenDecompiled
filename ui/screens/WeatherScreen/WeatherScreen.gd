extends "res://ui/screens/Screen.gd"

# TODO: Migrate exclusively to hardcoded data instead of random data!
# Right now, it's a mix of both.
const PRESETS = {
	"Ch5Sc5": [[1, 1, 1, 2, 2, 1, 1, 0], [0, 0, 1, 1, 0, 0, 1, 2]],
	"Ch5Sc10a": [[3, 5, 5, 5, 1, 1, 3, 4]]
}

@onready var tween = Threen.new()
@onready var header_content = $Header/Content
@onready var body_content = $Body/Content

@onready var location = $Header/Content/Location
@onready var icon_main = $Header/Content/IconMain
@onready var temp_main = $Header/Content/TempMain
@onready var descriptor = $Header/Content/Descriptor

@onready var nth_week_label = $Body/Content/WeekCycler/Label
@onready var prev_week_btn = $Body/Content/WeekCycler/Left
@onready var next_week_btn = $Body/Content/WeekCycler/Right
@onready var back_btn = $Menu/Label/BackButton

@onready var day_lines = [
	$Body/Content/Sunday,
	$Body/Content/Monday,
	$Body/Content/Tuesday,
	$Body/Content/Wednesday,
	$Body/Content/Thursday,
	$Body/Content/Friday,
	$Body/Content/Saturday
]

@export var weather_states := {}  # Map<String, Texture>
@export var weather_state_names: Array[String]
@export var weather_state_icons: Array[Texture2D]

var _seed := 23
var _preset := []
var _week_offset := 0
var _max_week_offset := 3
var _disable_input := false


func _enter_tree():
	bg_color = Color("#0877beb4")
	_seed = meta.get("seed", _seed)
	_preset = PRESETS.get(meta.get("preset", ""), [])


func _ready():
	add_child(tween)
	prev_week_btn.pressed.connect(_prev_week)
	next_week_btn.pressed.connect(_next_week)

	if meta.get("hide_back_btn", false):
		$Menu/Label/BackButton.hide()

	location.text = meta.get("location", "Bonifacio")
	_load()


func _load():
	var week_preset = Utils.array_get(_preset, _week_offset, [])
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed + _week_offset * 69

	for i in range(day_lines.size()):
		var day_line = day_lines[i]
		day_line.weather_idx = Utils.array_get(
			week_preset, i + 1, rng.randi() % (day_line.weather_icons.size() - 1)
		)  # Avoid rain in RNG

	var ws_idx = Utils.array_get(week_preset, 0, rng.randi() % (weather_state_names.size() - 1))  # Avoid rain in RNG
	icon_main.texture = weather_state_icons[ws_idx]
	descriptor.text = weather_state_names[ws_idx]

	temp_main.text = "%d°C" % rng.randi_range(30, 36)
	nth_week_label.text = _get_nth_week_text()

	prev_week_btn.modulate = Color.WHITE if _week_offset < _max_week_offset else Color.TRANSPARENT
	next_week_btn.modulate = Color.WHITE if _week_offset > 0 else Color.TRANSPARENT


func _load_animated():
	_disable_input = true
	await _fade_controls(false)
	_load()
	await Utils.wait(0.3)
	await _fade_controls(true)
	_disable_input = false


func _fade_controls(into: bool, dur: float = 0.3):
	var c = [Color.TRANSPARENT, Color.WHITE]
	var scale = [Vector2.ONE * 0.7, Vector2.ONE]
	if not into:
		c.reverse()
		scale.reverse()

	header_content.pivot_offset = header_content.size / 2
	body_content.pivot_offset = body_content.size * Vector2(0.5, 0)

	tween.interpolate_property(header_content, "modulate", c[0], c[1], dur)
	tween.interpolate_property(body_content, "modulate", c[0], c[1], dur)
	tween.interpolate_property(
		header_content, "scale", scale[0], scale[1], dur, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.interpolate_property(
		body_content, "scale", scale[0], scale[1], dur, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.start()

	await tween.tween_all_completed


func _get_nth_week_text():
	match _week_offset:
		0:
			return tr("WEATHERAPP_WEEK_TODAY")
		1:
			return tr("WEATHERAPP_WEEK_LAST_WEEK")
		_:
			return tr("WEATHERAPP_WEEK_NTH_WEEK") % _week_offset


func _prev_week():
	if _disable_input:
		return
	if _week_offset < _max_week_offset:
		_week_offset += 1
		_load_animated()



func _next_week():
	if _disable_input:
		return
	if _week_offset > 0:
		_week_offset -= 1
		_load_animated()

func _before_show():
	super._before_show()
	back_btn.disabled = true


func _after_show():
	super._after_show()
	get_tree().create_timer(1.0).timeout.connect(func(): back_btn.disabled = false)

func _before_hide():
	super._before_hide()
	back_btn.disabled = true

func _unhandled_input(event):
	if _disable_input:
		return
	if event.is_action_pressed("c_back"):
		_prev_week()
	if event.is_action_pressed("c_next"):
		_next_week()
	if event.is_action_pressed("c_cancel") and back_btn.visible:
		back_btn.press()
