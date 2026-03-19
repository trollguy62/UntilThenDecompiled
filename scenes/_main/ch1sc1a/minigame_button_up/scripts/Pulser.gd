@tool
extends CanvasItem

@export var modulate_low = Color(0, 0, 0, 0.06)
@export var modulate_high = Color(0, 0, 0, 0.13)
@export var speed = 5.0

var _t := 0.0


func _process(delta):
	if not visible:
		return

	_t += delta
	var x = sin(_t * speed) / 2 + 0.5
	modulate = lerp(modulate_low, modulate_high, x)
