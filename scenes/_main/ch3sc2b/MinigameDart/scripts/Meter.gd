extends Sprite2D

const to = -45
const from = 40
const _base_indicator_speed = 3.0
const _peak = 1.570796

@onready var indicator = $Indicator
@onready var tween = Threen.new()

var strength = 0
var indicator_speed := 1.0 : set = _set_indicator_speed
var active = false

var _t = 0.0
var _indicator_speed: float


func _ready():
	add_child(tween)
	set_process(false)


func start():
	active = true
	set_process(true)


func _process(delta):
	_t += delta
	_set_indicator_position()


func _set_indicator_position():
	var y = Utils.sin_bounded(_t, from, to, _indicator_speed)
	indicator.position = Vector2(indicator.position.x, y)
	strength = inverse_lerp(from, 0, y) if y > 0 else inverse_lerp(to, 0, y)


func stop():
	set_process(false)
	active = false


func reset_indicator_position():
	_t = _peak
	_set_indicator_position()


func _set_indicator_speed(val):
	_indicator_speed = _base_indicator_speed * val
