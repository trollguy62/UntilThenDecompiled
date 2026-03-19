extends Node

const OsuHitObject = preload("../../classes/beatmap/OsuHitObject.gd")


func _is_valid_mania_hit_object(obj: OsuHitObject) -> bool:
	#we dont use hitobjects that are neither holds nor hit circles
	return obj.type & (1 << OsuHitObject.TYPE_HOLD | 1 << OsuHitObject.TYPE_HIT_CIRCLE) != 0
