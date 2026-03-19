extends Sprite2D

@export var logos: Array
@export var change_time: float = 5.0  #seconds
var _t: float = 0
var _index: int = 0


func _process(delta):
	_t += delta
	if _t >= change_time:
		_renew_logo()


func _renew_logo():
	if logos.is_empty():
		return
	_index = (_index + 1) % logos.size()
	texture = logos[_index]
	_t = 0
