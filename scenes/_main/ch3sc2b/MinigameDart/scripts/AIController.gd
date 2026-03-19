extends Node

signal fire
signal aim_reposition
signal aiming_finish

const Board = preload("res://scenes/_main/ch3sc2b/MinigameDart/scripts/Board.gd")
const Crosshair = preload("res://scenes/_main/ch3sc2b/MinigameDart/scripts/Crosshair.gd")
const Meter = preload("res://scenes/_main/ch3sc2b/MinigameDart/scripts/Meter.gd")

const board_radius := 300

@onready var tween = Threen.new()

var aim_interval_rand_min: float
var aim_interval_rand_max: float
var aim_reposition_duration_rand_min: float
var aim_reposition_duration_rand_max: float

var board: Board
var crosshair: Crosshair
var meter: Meter
var is_aim_active: bool

var _rng = RandomNumberGenerator.new()
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _accuracy: float = -1


func _ready():
	add_child(tween)
	set_process(false)


func _process(delta):
	if _accuracy > -0.1:
		var strength = snapped(meter.strength, 0.1)
		var accuracy = snapped(_accuracy, 0.1)
		if strength == accuracy:
			trigger_fire()


func aim(aim_count, bullseye_tendency):
	is_aim_active = true
	meter.reset_indicator_position()
	var iteration = 0

	while true if aim_count == 0 else iteration < aim_count:
		var angle = randf_range(-180, 180)

		var from_accuracy = Vector2(cos(angle), sin(angle)) * _get_distance(bullseye_tendency)

		if _from == Vector2.ZERO:
			_from = Vector2(board.position.x + from_accuracy.x, board.position.y + from_accuracy.y)

		var to_accuracy = Vector2(cos(angle), sin(angle)) * _get_distance(bullseye_tendency)
		_to = Vector2(board.position.x + to_accuracy.x, board.position.y + to_accuracy.y)

		await Utils.wait(_get_aim_interval())
		tween.interpolate_property(
			crosshair,
			"position",
			_from,
			_to,
			_get_aim_reposition_duration(),
			Threen.TRANS_CUBIC,
			Threen.EASE_OUT
		)
		tween.start()

		await tween.tween_completed
		_from = _to
		iteration += 1

		aim_reposition.emit()

		if not is_aim_active:
			break

	is_aim_active = false
	aiming_finish.emit()


func aim_strength():
	await aiming_finish
	meter.start()
	set_process(true)


func trigger_fire():
	set_process(false)
	_accuracy = -1
	meter.stop()
	fire.emit()


func stop_aim():
	is_aim_active = false
	tween.stop_all()
	tween.tween_completed.emit()
	_from = Vector2.ZERO
	_to = Vector2.ZERO


func throw(accuracy: float):
	_accuracy = accuracy


# return distance from bullseye point
func _get_distance(bullseye_tendency) -> float:
	var from = randi() % board_radius
	return lerp(from, 0, bullseye_tendency)


func _get_aim_interval() -> float:
	return _rng.randf_range(aim_interval_rand_min, aim_interval_rand_max)


func _get_aim_reposition_duration() -> float:
	return _rng.randf_range(aim_reposition_duration_rand_min, aim_reposition_duration_rand_max)
