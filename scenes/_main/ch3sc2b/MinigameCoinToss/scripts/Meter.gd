extends Sprite2D

const _to = -46.499
const _from = 41.948
const _middle = -3
const _base_indicator_speed = 3.0
const _peak = 1.570796

@onready var indicator = $Indicator

var strength = 0
var indicator_speed := 1.0 : set =  _set_indicator_speed
var active = false

var _t = 0.0
var _indicator_speed: float


func _ready():
	set_process(false)


func start():
	active = true
	set_process(true)
	reset_indicator_position()


func _process(delta):
	_t += delta * _indicator_speed
	_set_indicator_position()


func _set_indicator_position():
	var y = Utils.sin_bounded(_t, _from, _to)
	indicator.position = Vector2(indicator.position.x, y)
	strength = inverse_lerp(_from, _middle, y) if y > _middle else inverse_lerp(_to, _middle, y)


func stop():
	set_process(false)
	active = false


func reset_indicator_position():
	_t = _peak
	_set_indicator_position()


func _set_indicator_speed(val):
	_indicator_speed = _base_indicator_speed * val
