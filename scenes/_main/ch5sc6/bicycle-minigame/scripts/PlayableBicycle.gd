extends PathFollow3D

@export var character: NodePath
@export var sprite_path: NodePath
@export var alias: String

@export var base_speed: float = 4.0  # m/s
@export var min_speed: float = 3.0
@export var max_speed: float = 4.5
@export var accel: float = 0.1
@export var frequency: float = 1.0
@export var amplitude: float = 1.0

@onready var tween = Threen.new()
@onready var state_container: StateContainer = Utils.get_state_container_of(alias)
@onready var timer = $Timer
@onready var sprite: AnimatedPaper3D = get_node(sprite_path)

var current_multiplier = 0
var time = 0
var path_position = progress_ratio : set = set_position, get = get_position
var idle_timer = 2
var talking = false
var timer_start = false


func set_position(val):
	progress_ratio = val


func get_position():
	return progress_ratio


var disabled = true : set = set_disabled


func set_disabled(val):
	disabled = val


var _speed = min_speed : set = set_speed


func set_speed(val):
	_speed = clamp(val, min_speed, max_speed)


var _target_speed = base_speed


func move_to(val):
	tween.interpolate_property(self, "progress_ratio", progress_ratio, float(val), 2)
	tween.start()


func _ready():
	add_child(tween)
	timer.timeout.connect(_on_timer_timeout)


func _process(delta):
	check_state()

	if disabled:
		return

#	if absf(_target_speed - _speed) > 0.1:
#		_speed += signf(_target_speed - _speed) * accel

	progress_ratio += delta * (_target_speed * 0.01)


func _physics_process(delta):
	time += delta
	var movement = cos(time * frequency) * amplitude
	get_node(character).position.x += movement * delta


func set_speed_multiplier(multiplier):
	current_multiplier = multiplier
	_target_speed = base_speed * current_multiplier
	sprite.speed_multiplier = clamp(1 + multiplier, 1, 2)


func is_talking():
	return talking


func _on_timer_timeout():
	talking = false


func check_state():
	var flags = state_container.flags
	var talk = flags.has("$talk")

	if talk:
		talking = true
		timer.stop()
		timer_start = false
		sprite.speed_multiplier = 1
	else:
		if not timer_start:
			timer.start(idle_timer)
			timer_start = true


func stop():
	disabled = true
	set_physics_process(false)
	sprite.speed_multiplier = 1
