extends CharacterBody2D

signal zero_tolerance(owned_by)
signal exit(npc)
signal driven_away(npc)

@export var speed_patrol := 60
@export var speed_run_away := 160
@export var disabled: bool : set = _set_disabled
@export var fear_reduction_time_normal = 1
@export var fear_reduction_time_scared = 0.1

@onready var sprite = $Sprite
@onready var path_finder = $Sprite/PathFinder
@onready var area = $Area2D
@onready var area_collider = $Area2D/CollisionShape2D
@onready var kinematic_collider = $CollisionShape2D
@onready var timer_run_away = $TimerRunAway
@onready var timer_select_point = $TimerSelectPoint
@onready var timer_reduce_fear = $TimerReduceFear
@onready var anim = $AnimationPlayer
@onready var ray = $RayCast2D
@onready var scream = $Scream

@onready var fear = $ProgressBar

var waypoints : set =_set_waypoints, get = _get_waypoints
var owned_by: String
var owned_ai_color: Color
var owned_player_color: Color

var _selected_point: Vector2
var _exit_point: Vector2
var _waypoints: PackedVector2Array
var _disabled: bool
var _is_scared: bool

var _owned_ai_color: Color
var _owned_player_color: Color
var _pursuer: CharacterBody2D


func _ready():
	timer_reduce_fear.wait_time = fear_reduction_time_normal

	path_finder.target_reach.connect(_on_target_point_reached)
	path_finder.change_direction.connect(_on_change_direction)
	area.area_entered.connect(_on_area_entered)
	timer_run_away.timeout.connect(_on_run_away_timedout)
	timer_reduce_fear.timeout.connect(_on_reduce_fear_timedout)

	path_finder.speed = speed_patrol
	path_finder.disabled = _disabled


func _on_area_entered(pursuer: Area2D):
	ray.enabled = true
	_pursuer = pursuer.get_parent()


func _physics_process(delta):
	if _pursuer:
		var pos = _pursuer.position - position
		ray.target_position = pos * 7

		if ray.get_collider():
			var object = ray.get_collider()

			if "Player" in object.name or "AI" in object.name:
				_pursuer.chase()
				_run_away()


func _set_waypoints(value):
	_waypoints = value

	var exit_index = _waypoints.size() - 1
	_exit_point = _waypoints[exit_index]
	_waypoints.remove_at(exit_index)

	_goto_a_random_point()


func _get_waypoints():
	return _waypoints


func _goto_position(target_position: Vector2):
	path_finder.move(self, position, target_position)


func _goto_a_random_point():
	var point = await _select_random_point()
	_goto_position(point)


func _select_random_point() -> Vector2:
	var selected_point = Vector2.ZERO

	# prevents selecting current position
	while true:
		var i = randi() % _waypoints.size()
		selected_point = _waypoints[i]

		if _selected_point != selected_point:
			timer_select_point.start()
			break

	_selected_point = selected_point

	# timer instead of Utils.wait to prevent GDScriptFunctionState resume error
	await timer_select_point.timeout
	return selected_point


func _on_target_point_reached():
	_goto_a_random_point()


func _run_away():
	if _pursuer == null:
		_patrol()
		return

	if timer_run_away.time_left > 0:
		return

	if fear.value > 0:
		owned_by = _pursuer.name

		match owned_by:
			"Player":
				fear.modulate = owned_player_color
			"AI":
				fear.modulate = owned_ai_color

	_selected_point = Vector2.ZERO

	timer_run_away.start()
	area_collider.set_deferred("disabled", true)
	kinematic_collider.set_deferred("disabled", true)

	path_finder.speed = speed_run_away

	timer_reduce_fear.wait_time = fear_reduction_time_scared

	_is_scared = true
	driven_away.emit(self)
	scream.play()
	_on_change_direction()


func _patrol():
	_goto_a_random_point()
	area_collider.set_deferred("disabled", false)
	kinematic_collider.set_deferred("disabled", false)
	path_finder.speed = speed_patrol
	_clear_pursuer()


func _goto_exit():
	_goto_position(_exit_point)


func _on_run_away_timedout():
	if fear.value <= 0:
		return

	_is_scared = false
	_patrol()

	if fear.value > 0:
		fear.modulate = Color(1, 1, 1, 1)

	timer_reduce_fear.wait_time = fear_reduction_time_normal
	_clear_pursuer()


func _on_reduce_fear_timedout():
	fear.value -= 1

	if fear.value <= 0:
		_goto_exit()

		if fear.visible:
			zero_tolerance.emit(owned_by)
			fear.visible = false

	if _is_in_exit_point():
		exit.emit(self)
		queue_free()


func _is_in_exit_point() -> bool:
	return position.distance_to(_exit_point) <= 10


func _set_disabled(value):
	_disabled = value
	path_finder.disabled = value
	timer_reduce_fear.paused = value

	if not disabled:
		_goto_a_random_point()


func _clear_pursuer():
	ray.target_position = Vector2.ZERO * 0
	ray.enabled = false
	_pursuer = null


func _on_change_direction():
	var direction = path_finder.current_direction
	direction = Vector2(round(direction.x), round(direction.y))
	match direction:
		Vector2.DOWN:
			if not _is_scared:
				anim.play("f_idle_walk")
			else:
				anim.play("f_scared_walk")
		Vector2.UP:
			if not _is_scared:
				anim.play("b_idle_walk")
			else:
				anim.play("b_scared_walk")
		Vector2.LEFT:
			if not _is_scared:
				anim.play("l_idle_walk")
			else:
				anim.play("l_scared_walk")
		Vector2.RIGHT:
			if not _is_scared:
				anim.play("r_idle_walk")
			else:
				anim.play("r_scared_walk")
