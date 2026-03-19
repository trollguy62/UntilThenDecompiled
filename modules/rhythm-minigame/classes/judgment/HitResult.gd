extends RefCounted

enum {
	HIT_RESULT_NONE,
	HIT_RESULT_MISS,
	HIT_RESULT_GREAT,
	HIT_RESULT_PERFECT,
}
#
var type: int = HIT_RESULT_NONE

var score_value: int = 0:
	get:
		match type:
			HIT_RESULT_NONE:
				return 0
			HIT_RESULT_MISS:
				return 0
			HIT_RESULT_GREAT:
				return 75
			HIT_RESULT_PERFECT:
				return 100
			_:
				printerr("Unknown hit result type")
				return 0


var affects_combo: bool = false:
	get:
		match type:
			HIT_RESULT_NONE:
				return false
			HIT_RESULT_MISS:
				return false
			HIT_RESULT_GREAT:
				return true
			HIT_RESULT_PERFECT:
				return true
			_:
				printerr("Unknown hit result type")
				return true


var hit_error_msec: float = 0


func _init(type_: int = HIT_RESULT_NONE):
	type = type_
