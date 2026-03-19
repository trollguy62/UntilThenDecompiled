extends CharacterBody2D

@export var npcs_path : NodePath
@export var disabled: bool : set = _set_disabled
@export_range(0, 100) var intelligence = 100
@export var idle_time = 2

@onready var path_finder = $Sprite/PathFinder
@onready var timer_idle = $TimerIdle
@onready var timer_select_point = $TimerSelectPoint
@onready var timer_pathfind = $TimerPathfind
@onready var timer_chase = $TimerChase
@onready var anim = $AnimationPlayer
@onready var area = $AIRange
@onready var area_collider = $AIRange/CollisionShape2D
@onready var kinematic_collider = $CollisionShape2D

var npcs : set =_set_npcs, get = _get_npcs
var waypoints = []

var _npcs = []
var _target_npc: CharacterBody2D
var _selected_point: Vector2
var _disabled = false
var _is_chasing = false


func _ready():
	timer_idle.wait_time = idle_time

	path_finder.target_reach.connect(_on_target_reached)
	path_finder.change_direction.connect(_on_change_direction)
	timer_idle.timeout.connect(_on_timer_idle_timeout)
	timer_pathfind.timeout.connect(_on_timer_pathfind_timedout)
	timer_chase.timeout.connect(_on_timer_chase_timeout)

	path_finder.disabled = _disabled


func _select_target_npc():
	if _npcs.size() == 0:
		return

	# initial target
	if _target_npc == null:
		_select_random_target_npc()
		return

	# do AI go stupid sometimes and change NPC its chasing?
	var change_target_chance = randi() % 100
	if change_target_chance > intelligence:
		_select_random_target_npc()
		return

	# select the npc with least fear value
	var fear_value = INF
	for npc in _npcs:
		if npc.fear.value == 0:
			continue

		if npc.fear.value < fear_value:
			_target_npc = npc


func _select_random_target_npc():
	var i = randi() % _npcs.size()
	if _npcs[i] == null:
		return
	_target_npc = _npcs[i]


func _on_timer_pathfind_timedout():
	if _target_npc == null or disabled:
		return

	if is_instance_valid(_target_npc):
		_goto_position(_target_npc.position)


func _get_npcs():
	return _npcs


func _set_npcs(value):
	_npcs = value
	_select_target_npc()


func _on_npc_exited(npc):
	_target_npc = null
	_select_target_npc()


func chase():
	if _is_chasing:
		return

	_is_chasing = true

	var go_idle = randi() % 100
	var is_go_idle_sucessful = go_idle > intelligence

	if is_go_idle_sucessful:
		_go_idle()

	timer_chase.start()


func _goto_a_random_point():
	var point = await _select_random_point()
	_goto_position(point)


func _goto_position(target_position: Vector2):
	path_finder.move(self, position, target_position)


func _select_random_point() -> Vector2:
	var selected_point = Vector2.ZERO

	# prevents selecting current position
	while true:
		var i = randi() % waypoints.size()
		selected_point = waypoints[i]

		if _selected_point != selected_point:
			timer_select_point.start()
			break

	_selected_point = selected_point

	await timer_select_point.timeout
	return selected_point


func _go_idle():
	timer_idle.start()
	var point = await _select_random_point()
	_goto_position(point)


func _on_timer_idle_timeout():
	_select_target_npc()


func _on_timer_chase_timeout():
	_is_chasing = false


func _on_target_reached():
	_select_target_npc()


func _set_disabled(value):
	_disabled = value
	call_deferred("_disable", _disabled)


func _disable(_disabled):
	if path_finder != null:
		path_finder.disabled = _disabled

	area_collider.set_deferred("disabled", _disabled)
	kinematic_collider.set_deferred("disabled", _disabled)


func _on_change_direction():
	var direction = path_finder.current_direction
	direction = Vector2(round(direction.x), round(direction.y))
	match direction:
		Vector2.DOWN:
			if not _is_chasing:
				anim.play("f_idle_walk")
			else:
				anim.play("f_chase_walk")
		Vector2.UP:
			if not _is_chasing:
				anim.play("b_idle_walk")
			else:
				anim.play("b_chase_walk")
		Vector2.LEFT:
			if not _is_chasing:
				anim.play("l_idle_walk")
			else:
				anim.play("l_chase_walk")
		Vector2.RIGHT:
			if not _is_chasing:
				anim.play("r_idle_walk")
			else:
				anim.play("r_chase_walk")
