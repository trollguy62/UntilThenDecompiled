extends Label

@export var perfect_label: LabelSettings
@export var great_label: LabelSettings
@export var miss_label: LabelSettings

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const MAX_WIDTH = 68

@onready var _t := Threen.new()
@onready var _hide_timer := $HideTimer

var original_scale = Vector2.ONE


func _ready():
	add_child(_t)
	text = ""
	original_scale = scale
	_hide_timer.timeout.connect(hide_visuals)
	resized.connect(_on_resized)

func apply_result(hit_result):
	var ls: LabelSettings

	match hit_result.type:
		HitResult.HIT_RESULT_PERFECT:
			ls = perfect_label
			text = "MG_RHYTHM_JUDG_PERFECT"
		HitResult.HIT_RESULT_GREAT:
			ls = great_label
			text = "MG_RHYTHM_JUDG_GREAT"
		HitResult.HIT_RESULT_MISS:
			ls = miss_label
			text = "MG_RHYTHM_JUDG_MISS"

	if hit_result.type != HitResult.HIT_RESULT_NONE:
		label_settings = ls.duplicate()
		wipe_in()


func wipe_in():
	_t.remove_all()
	_t.interpolate_property(
		self, "scale", Vector2(original_scale.x / 2, 0.0), original_scale, 0.3, Threen.TRANS_ELASTIC
	)
	_t.start()
	_hide_timer.start()


func hide_visuals():
	_t.remove_all()
	_t.interpolate_property(self, "scale", original_scale, Vector2.ZERO, 0.3, Threen.TRANS_EXPO)
	_t.start()

func _on_resized():
	if size.x > MAX_WIDTH:
		label_settings.font_size -= 1
		size = custom_minimum_size
		anchors_preset = PRESET_FULL_RECT

	pivot_offset = size / 2.0
