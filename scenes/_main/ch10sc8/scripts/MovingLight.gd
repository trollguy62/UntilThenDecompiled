extends Light3D

@export var direction = Vector3(0, 0, 1)
@export var velocity = 0.0
@export var max_distance = 8.0
@export var random_interval_min = 0.0
@export var random_interval_max = 16.0

@onready var _timer := Timer.new()

var _initial_global_transform: Transform3D
var _moving := false


func _ready():
	_initial_global_transform = global_transform

	_timer.one_shot = true
	_timer.timeout.connect(func(): _moving = true)
	add_child(_timer)


func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		global_transform = _initial_global_transform
		visible = false


func _process(delta):
	visible = _moving

	if _moving:
		if _initial_global_transform.origin.distance_to(global_transform.origin) >= max_distance:
			_moving = false
			global_transform = _initial_global_transform
		else:
			translate(direction * velocity * delta)
	elif _timer.is_stopped():
		_timer.start(randf_range(random_interval_min, random_interval_max))
