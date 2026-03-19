extends Label

signal value_changed(value)

@export var idle_wait_time = 3.0:
	set(v):
		idle_timer.wait_time = v
		idle_wait_time = v


var value: int:
	get:
		assert(digits.size() == 4)
		var val: int = 0
		for i in digits.size():
			val += digits[i] * pow(10, digits.size() - i - 1)

		return val


var digits: Array = [0, 0, 0, 0]
var is_idle = false

@onready var idle_timer = $IdleTimer


func _ready():
	idle_timer.timeout.connect(_on_idle_timer_timeout)


func push_digit(digit: int):
	assert(digit <= 9 && digit >= 0)
	#FIXME: hack
	if is_idle:
		for i in digits.size():
			digits[i] = 0
	#
	digits.pop_front()
	digits.push_back(digit)
	text = str(self.value).pad_zeros(4)
	idle_timer.start()
	is_idle = false
	value_changed.emit(self.value)


func reset():
	digits = [0, 0, 0, 0]
	text = str(self.value).pad_zeros(4)
	value_changed.emit(self.value)


func set_value(val: int):
	text = str(val).pad_zeros(4)
	value = val
	value_changed.emit(self.value)


func _on_idle_timer_timeout():
	is_idle = true
