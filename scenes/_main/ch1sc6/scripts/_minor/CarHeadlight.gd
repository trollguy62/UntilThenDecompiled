extends SpotLight3D

@export var from = 5.0
@export var to = 2.5
@export var period = 3.0

@onready var sfx_motor = $Motorcycle
@onready var sfx_car = $Car

@onready var sfx_list = [sfx_motor, sfx_car]

var _sfx_i := -1


func _enter_tree():
	position.z = from


func _ready():
	_cycle_sfx()


func _cycle_sfx():
	var sfx_count = sfx_list.size()
	_sfx_i = (_sfx_i + 1) % sfx_count

	for i in range(sfx_count):
		var sfx = sfx_list[i]
		if i == _sfx_i:
			sfx.play()
		else:
			sfx.stop()


func _process(_delta):
	var t = fmod(Utils.t, period) / period
	var old_z = position.z
	position.z = lerp(from, to, t)

	if abs(old_z - position.z) > 1:
		_cycle_sfx()
