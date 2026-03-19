extends Light3D

const K = 5

@export_range(0.0, 1.0) var max_light_energy = 0.12
@export_range(0.0, 8.0) var min_lifetime = 1
@export_range(0.0, 8.0) var max_lifetime = 2
@export_range(0.0, 32.0) var min_interval = 1
@export_range(0.0, 32.0) var max_interval = 1
@export_color_no_alpha var base_color
@export var override = false
@onready var _timer := Timer.new()
var _active := false


func _ready():
	assert(min_lifetime <= max_lifetime)
	assert(min_interval <= max_interval)

	_timer.timeout.connect(_on_timer_timeout)

	_timer.one_shot = true
	add_child(_timer)

	_schedule()


func _process(_delta):
	if override:
		return
	if _active:
		var t = 1.0 - (_timer.time_left / _timer.wait_time)
		var y = 1 - pow(abs(2 * (t - 0.5)), K)
		light_energy = y * max_light_energy
	else:
		light_energy = 0.0

func reset_color():
	light_color = base_color

func _schedule():
	_active = false
	_timer.start(randf_range(min_interval, max_interval))


func _light_up():
	_active = true
	_timer.start(randf_range(min_lifetime, max_lifetime))


func _on_timer_timeout():
	if not _active and is_visible_in_tree():
		_light_up()
	else:
		_schedule()
