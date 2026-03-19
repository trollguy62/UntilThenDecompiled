extends Control

signal celebratory_sfx_ended

@onready var score_label = $Score
@onready var caption_label = $MarginContainer/Caption
@onready var roll_timer: Timer = $RollTimer
@onready var msg_delay: Timer = $MessageDelay

var is_rolling = false
var numeric_score: int = 96:
	set(v):
		var comment = _get_complementary_message(v)
		score_label.text = str(numeric_score).pad_zeros(2)
		caption_label.text = String(comment)
		numeric_score = v


var message_delay: float = 1.0

var _min_roll_value: int = 1
var _max_roll_value: int = 100


func _ready():
	Utils.randomize()
	roll_timer.timeout.connect(_on_roll_timer_timeout)
	msg_delay.timeout.connect(_on_message_timer_timeout)


func _process(delta):
	if is_rolling:
		score_label.text = str(_get_roll_value()).pad_zeros(2)


func animate_roll(min_value: int = 1, max_value: int = 100, duration: float = 1.0):
	is_rolling = true
	_min_roll_value = min_value
	_max_roll_value = max_value
	caption_label.hide()
	roll_timer.start(duration)
	msg_delay.start(message_delay)


func _get_complementary_message(score: int):
	assert(score >= 0 && score <= 100)
	if score == 100:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET1_1",
				"MG_KARAOKE_MSG_SET1_2",
				"MG_KARAOKE_MSG_SET1_3",
				"MG_KARAOKE_MSG_SET1_4",
				"MG_KARAOKE_MSG_SET1_5"
			]
		)
	elif score >= 90:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET2_1",
				"MG_KARAOKE_MSG_SET2_2",
				"MG_KARAOKE_MSG_SET2_3",
				"MG_KARAOKE_MSG_SET2_4",
				"MG_KARAOKE_MSG_SET2_5",
				"MG_KARAOKE_MSG_SET2_6",
				"MG_KARAOKE_MSG_SET2_7",
				"MG_KARAOKE_MSG_SET2_8"
			]
		)
	elif score >= 80:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET3_1",
				"MG_KARAOKE_MSG_SET3_2",
				"MG_KARAOKE_MSG_SET3_3",
				"MG_KARAOKE_MSG_SET3_4",
				"MG_KARAOKE_MSG_SET3_5",
				"MG_KARAOKE_MSG_SET3_6",
				"MG_KARAOKE_MSG_SET3_7",
				"MG_KARAOKE_MSG_SET3_8",
				"MG_KARAOKE_MSG_SET3_9",
			]
		)
	elif score >= 70:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET4_1",
				"MG_KARAOKE_MSG_SET4_2",
				"MG_KARAOKE_MSG_SET4_3",
				"MG_KARAOKE_MSG_SET4_4",
				"MG_KARAOKE_MSG_SET4_5",
				"MG_KARAOKE_MSG_SET4_6",
				"MG_KARAOKE_MSG_SET4_7",
				"MG_KARAOKE_MSG_SET4_8",
				"MG_KARAOKE_MSG_SET4_9",
				"MG_KARAOKE_MSG_SET4_10",
			]
		)
	elif score > 20:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET5_1",
				"MG_KARAOKE_MSG_SET5_2",
				"MG_KARAOKE_MSG_SET5_3",
				"MG_KARAOKE_MSG_SET5_4",
			]
		)
	elif score > 0:
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET6_1",
				"MG_KARAOKE_MSG_SET6_2",
				"MG_KARAOKE_MSG_SET6_3",
				"MG_KARAOKE_MSG_SET6_4",
				"MG_KARAOKE_MSG_SET6_5",
				"MG_KARAOKE_MSG_SET6_6"
			]
		)
	else:  # 0
		return _pick_any(
			[
				"MG_KARAOKE_MSG_SET7_1",
				"MG_KARAOKE_MSG_SET7_2",
				"MG_KARAOKE_MSG_SET7_3",
				"MG_KARAOKE_MSG_SET7_4",
				"MG_KARAOKE_MSG_SET7_5",
				"MG_KARAOKE_MSG_SET7_6",
				"MG_KARAOKE_MSG_SET7_7",
				"MG_KARAOKE_MSG_SET7_8",
				"MG_KARAOKE_MSG_SET7_9",
				"MG_KARAOKE_MSG_SET7_10",
			]
		)


func _get_roll_value():
	return randi() % (_max_roll_value - _min_roll_value) + _min_roll_value + 1


func _pick_any(from: Array):
	return from[randi() % from.size()]


func _on_roll_timer_timeout():
	is_rolling = false
	score_label.text = str(numeric_score)
	celebratory_sfx_ended.emit()


func _on_message_timer_timeout():
	caption_label.show()
