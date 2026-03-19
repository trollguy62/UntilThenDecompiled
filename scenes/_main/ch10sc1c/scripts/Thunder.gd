extends WorldEnvironment

@export var enabled = false
@export var background_color = Color("#9eabdd")
@export var background_energy = 1.6
@export var random_interval_min = 2.0
@export var random_interval_max = 48.0

@onready var _timer = Timer.new()
@onready var _thunder_sfx = $Thunder

var _initial_background_color: Color
var _initial_background_energy: float


func _ready():
	assert(environment != null)
	_initial_background_color = environment.background_color
	_initial_background_energy = environment.background_energy_multiplier

	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)

	_schedule_next()


func _on_timer_timeout():
	if enabled:
		await _fire()
	_schedule_next()


func _schedule_next():
	_timer.start(randf_range(random_interval_min, random_interval_max))


func _fire():
	for i in randi_range(1, 3):
		var tween = create_tween()
		var energy = background_energy * randf_range(0.8, 1.0)
		var duration = randf_range(0.04, 0.12)

		tween.tween_property(environment, "background_color", background_color, duration)
		tween.tween_property(environment, "background_energy_multiplier", energy, duration)

		tween.chain().tween_property(environment, "background_color", _initial_background_color, duration)
		tween.tween_property(environment, "background_energy_multiplier", _initial_background_energy, duration)

		await tween.finished
		await get_tree().create_timer(randf_range(0, 0.16)).timeout
		
		_thunder_sfx.play()
