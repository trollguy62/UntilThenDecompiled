extends Node

signal fire
signal aim_reposition
signal aiming_finish

const Board = preload("res://scenes/_main/ch3sc2b/MinigameDart/scripts/Board.gd")
const Crosshair = preload("res://scenes/_main/ch3sc2b/MinigameCoinToss/scripts/Crosshair.gd")
const Meter = preload("res://scenes/_main/ch3sc2b/MinigameCoinToss/scripts/Meter.gd")

const board_radius := 300

@export_range( 0, 1) var cathy_int = 0.5
@export_range( 0, 1) var ridel_int = 0.5

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
	_rng.seed = randi()
	set_process(false)


func _process(delta):
	if _accuracy > -0.1:
		var strength = snapped(meter.strength, 0.1)
		var accuracy = snapped(_accuracy, 0.1)
		if strength == accuracy:
			trigger_fire()


func aim(aim_count, accuracy):
	is_aim_active = true
	meter.reset_indicator_position()
	var iteration = 0

	while true if aim_count == 0 else iteration < aim_count:
		if _from == Vector2.ZERO:
			_from = _get_random_point()
		var _to = _get_random_point()

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
	meter.start()
	set_process(true)


func trigger_fire():
	set_process(false)
	_accuracy = -1
	meter.stop()
	crosshair.flash()
	fire.emit()


func stop_aim():
	is_aim_active = false
	tween.stop_all()
	tween.tween_completed.emit()
	_from = Vector2.ZERO
	_to = Vector2.ZERO


func toss(accuracy: float):
	_accuracy = accuracy


func _get_random_point():
	var point = Vector2.ZERO

	var board_pos = board.position
	var width = board.texture.get_width() * 3.2
	var height = board.texture.get_height() * 3.2

	point.x = _rng.randf_range(board_pos.x, width)
	point.y = _rng.randf_range(board_pos.y, height)

	point.x = clamp(point.x, board_pos.x + 60, width)
	point.y = clamp(point.y, board_pos.y + 60, height)

	return point


func _get_aim_interval() -> float:
	return _rng.randf_range(aim_interval_rand_min, aim_interval_rand_max)


func _get_aim_reposition_duration() -> float:
	return _rng.randf_range(aim_reposition_duration_rand_min, aim_reposition_duration_rand_max)
