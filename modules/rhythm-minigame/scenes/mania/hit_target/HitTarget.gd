extends Node2D

signal new_result(result)

@export var speed = 1000.0  #px/s
@export var lead_in_msec = 1000.0  #ms
@export var base_lifetime = 0.0  #ms
@export var force_miss_on_input_change = false

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const HitInput = preload("res://modules/rhythm-minigame/classes/input/HitInput.gd")
const HitJudge = preload("res://modules/rhythm-minigame/classes/judgment/HitJudge.gd")
const OsuHitObject = preload("res://modules/rhythm-minigame/classes/beatmap/OsuHitObject.gd")

var target_hit_input: HitInput
var is_head_or_tail: bool = false
var texture: Texture:
	set(v):
		sprite.texture = v
		texture = v
		if texture:
			var t_scale = 64.0 / texture.get_height()
			sprite.scale = Vector2(t_scale, t_scale)


var is_judged: bool = false:
	get:
		return result.type != HitResult.HIT_RESULT_NONE


var result: HitResult = HitResult.new():
	set(v):
		if v.type != HitResult.HIT_RESULT_NONE:
			result = v
			new_result.emit(result)
			if not is_head_or_tail or v.type != HitResult.HIT_RESULT_MISS:
				hide()
				queue_free()


var _timestamp_spawned_msec: int = 0
var _t: float = 0

@onready var sprite = $Sprite

func _ready():
	sprite.texture = texture
	_timestamp_spawned_msec = Time.get_ticks_msec()


func _process(delta):
	_update(delta)


func _update(delta):
	_t += delta
	if has_hit_miss_threshold():
		force_miss()


func check_result(hi: HitInput):
	var judgment: HitJudge = HitJudge.new()
	var res: HitResult = judgment.compare(hi, target_hit_input)

	if force_miss_on_input_change && res.type == res.HIT_RESULT_NONE:
		force_miss()
	else:
		self.result = res


func force_miss():
	self.result = HitResult.new(HitResult.HIT_RESULT_MISS)


func has_hit_miss_threshold():
	#FIXME: hacky, should eventually refactor to use a synchronized timestamp but this works for now
	return (_t * 1000.0) - (lead_in_msec + base_lifetime) >= HitJudge.thresholds_ms["miss"]
