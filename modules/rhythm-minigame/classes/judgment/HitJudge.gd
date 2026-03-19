extends RefCounted

const HitResult = preload("./HitResult.gd")
const HitInput = preload("../input/HitInput.gd")
const thresholds_ms: Dictionary = {
	"perfect": 120.0,
	"great": 300.0,
	"miss": 320.0,
}


func compare(hit_input: HitInput, target: HitInput) -> HitResult:
	var hit_result: HitResult = HitResult.new()

	#FIXME: hack
	if !hit_input || !target:
		hit_result.type = HitResult.HIT_RESULT_NONE
		return hit_result

	if hit_input.column != target.column:
		hit_result.type = HitResult.HIT_RESULT_NONE
		return hit_result

	if hit_input.is_pressed != target.is_pressed:
		hit_result.type = HitResult.HIT_RESULT_NONE
		return hit_result

	var hit_error_msec: float = hit_input.timestamp - target.timestamp
	var thresholds := thresholds_ms

	hit_result.hit_error_msec = hit_error_msec

	if abs(hit_error_msec) < thresholds["perfect"]:
		hit_result.type = HitResult.HIT_RESULT_PERFECT

	elif abs(hit_error_msec) < thresholds["great"]:
		hit_result.type = HitResult.HIT_RESULT_GREAT

	elif abs(hit_error_msec) < thresholds["miss"]:
		hit_result.type = HitResult.HIT_RESULT_MISS

	else:
		hit_result.type = HitResult.HIT_RESULT_NONE

	return hit_result
