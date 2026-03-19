extends Sprite2D

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")

@onready var tween = Threen.new()
@onready var hide_timer = $Timer

var show_time = 0.67
var perfect_color = Color(0.52549, 0.654902, 0.541176)
var great_color = Color(0.760784, 0.721569, 0.458824)
var miss_color = Color(0.694118, 0.498039, 0.498039)


func _ready():
	add_child(tween)
	hide_timer.timeout.connect(hide_visuals)
	hide_visuals()


func apply_result(hit_result):
	match hit_result.type:
		HitResult.HIT_RESULT_PERFECT:
			self_modulate = perfect_color
		HitResult.HIT_RESULT_GREAT:
			self_modulate = great_color
		HitResult.HIT_RESULT_MISS:
			self_modulate = miss_color

	show_highlight()


func show_highlight():
	var from_color = Color(self_modulate, 0)
	var to_color = Color(self_modulate, 1)
	tween.remove_all()
	tween.interpolate_property(self, "self_modulate", from_color, to_color, 0.2, Threen.TRANS_LINEAR)
	tween.start()
	hide_timer.start(show_time)


func hide_visuals():
	var from_color = Color(self_modulate, 1)
	var to_color = Color(self_modulate, 0)
	tween.remove_all()
	tween.interpolate_property(self, "self_modulate", from_color, to_color, 0.2, Threen.TRANS_LINEAR)
	tween.start()
