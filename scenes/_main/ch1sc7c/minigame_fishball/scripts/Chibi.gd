extends AnimatedSprite2D

@export var circle_color := Color.BLACK

@onready var tween = Threen.new()
@onready var circle = $Circle

var active := false : set = _set_active,get = _get_active

var _shake_t = 999


func _ready():
	add_child(tween)
	self.active = active


func _process(delta):
	_shake_t += delta
	offset.y = Utils.spring(_shake_t, 8, 0.75, 16)


func _set_active(value):
	active = value
	if tween:
		var c = [circle.modulate, circle_color if active else Color.WHITE]
		tween.stop_all()
		tween.interpolate_property(circle, "modulate", c[0], c[1], 0.25)
		tween.start()


func _get_active():
	return active


func shake():
	_shake_t = 0
