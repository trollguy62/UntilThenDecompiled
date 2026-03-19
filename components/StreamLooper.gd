extends Node

@export var enabled := true
@export_range(0.01, 1000) var gap: float = 1.0
@export var gap_max_random := 0.0

var _gap_t := 0.0
var _gap := 0.0


func _process(delta):
	if not enabled:
		return

	if not get("playing"):
		if gap_max_random > gap:
			_gap = randf_range(gap, gap_max_random)
		else:
			_gap = gap

	if _gap > 0:
		_gap_t += delta
		if _gap_t >= _gap:
			_gap = 0
			_gap_t = 0
			call("play")
