extends Node

signal fire
signal aim_reposition

const Crosshair = preload("res://scenes/_main/ch3sc2b/MinigameBalloon/scripts/Crosshair.gd")
const Balloon = preload("res://scenes/_main/ch3sc2b/MinigameBalloon/scripts/Balloon.gd")

@export_range(0, 1) var cathy_int = 0.5
@export_range(0, 1) var ridel_int = 0.5

@onready var tween = Threen.new()

var _rng = RandomNumberGenerator.new()
var _is_aim_active: bool

var aim_interval_rand_min: float
var aim_interval_rand_max: float
var aim_reposition_duration_rand_min: float
var aim_reposition_duration_rand_max: float
var aim_fire_delay: float

var balloons: Node2D
var crosshair: Crosshair

func _ready():
	add_child(tween)

func aim(aim_count):
	_is_aim_active = true

	var from = crosshair.position
	var to = Vector2.ZERO
	var iteration = 0

	aim_count = INF if aim_count == 0 else aim_count

	while iteration < aim_count:
		iteration += 1

		var target_balloon = _pick_balloon()
		from = await _reposition_to(from, target_balloon)

		if aim_count != INF and iteration == aim_count:
			_fire()

		if not _is_aim_active:
			break


func _reposition_to(from, target_balloon) -> Vector2:
	var to = Vector2(target_balloon.position.x, target_balloon.position.y)

	await Utils.wait(_get_aim_interval())
	await _move(from, to, _get_aim_reposition_duration())
	aim_reposition.emit()
	await Utils.wait(aim_fire_delay)

	return to


func reposition_tugged(from, tug_duration, tug_max_distance):
	crosshair.is_tugging = true
	crosshair.force_shake = true
	crosshair.is_player_active = false

	var angle = _rng.randi_range(0, 2 * PI)
	var to_accuracy = Vector2(cos(angle), sin(angle)) * tug_max_distance
	var to = Vector2(crosshair.position.x + to_accuracy.x, crosshair.position.y + to_accuracy.y)

	await _move(from, to, tug_duration, Threen.EASE_IN)

	crosshair.is_player_active = true
	crosshair.is_tugging = false


func _move(from, to, duration, easing = Threen.EASE_OUT):
	tween.interpolate_property(crosshair, "position", from, to, duration, Threen.TRANS_CUBIC, easing)
	tween.start()
	await tween.tween_all_completed


func stop_aim():
	_is_aim_active = false
	tween.stop_all()
	tween.tween_all_completed.emit()


func _fire():
	fire.emit()


func _pick_balloon() -> Balloon:
	var balloon: Balloon

	var iteration = 0
	var total_balloons = balloons.get_child_count()

	while true:
		var index = randi() % total_balloons
		balloon = balloons.get_child(index)
		if not balloon.is_popped:
			break

		if iteration == total_balloons:
			_is_aim_active = false
			break

		iteration += 1

	return balloon


# return distance from target point
func _get_distance() -> float:
	return 0.0


func _get_aim_interval() -> float:
	return _rng.randf_range(aim_interval_rand_min, aim_interval_rand_max)


func _get_aim_reposition_duration() -> float:
	return _rng.randf_range(aim_reposition_duration_rand_min, aim_reposition_duration_rand_max)
