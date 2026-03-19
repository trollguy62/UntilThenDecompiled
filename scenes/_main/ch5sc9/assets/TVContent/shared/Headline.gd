extends Panel

@export var texts: Array[Texture] = []

@export var local_pos_enter := Vector2(0, 0)
@export var local_pos_show := Vector2(1, 0)
@export var local_pos_exit := Vector2(2, 0)

@export var cycle_interval_min: float = 4.0
@export var cycle_interval_max: float = 8.0

@export var move_duration: float = 0.75
@export var tween_trans: int = Threen.TRANS_LINEAR

@onready var timer = $Timer
@onready var tween = $Tween
@onready var text_rect = $Text

var _text_idx = -1


func _ready():
	assert(not texts.is_empty())

	timer.timeout.connect(_on_timer_timeout)

	text_rect.texture = null
	_on_timer_timeout()


func _on_timer_timeout():
	await _cycle()

	var delay = randf_range(cycle_interval_min, cycle_interval_max)
	timer.start(delay)


func _cycle():
	await _move(false)

	_text_idx = int(fmod(_text_idx + 1, texts.size()))
	text_rect.texture = texts[_text_idx]

	await _move(true)


func _move(into: bool):
	var p0 = local_pos_enter if into else local_pos_show
	var p1 = local_pos_show if into else local_pos_exit

	tween.interpolate_property(text_rect, "position", p0, p1, move_duration, tween_trans)
	tween.start()
	await tween.tween_completed
