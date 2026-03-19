extends Node

signal target_reach
signal change_direction


@export var speed := 160
@export var disabled := false
@export var optimize_path = false

var tilemap: TileMap
var current_direction: Vector2

var _map
var _object: CharacterBody2D
var _path  # Cell[]
var _direction := Vector2.ZERO  # movement direction


func _ready():
	set_physics_process(false)
	call_deferred("setup_navserver")

func setup_navserver():
	_map = tilemap.get_navigation_map(0)
	NavigationServer2D.map_set_active(_map,true)

# @param1: object to move. eg: KinematicBody2D/Sprite/...
func move(object, start_position: Vector2, target_position: Vector2):
	_path = NavigationServer2D.map_get_path(_map,start_position,target_position,optimize_path)
	if _path == null:
		return

	_object = object
	_path.remove_at(0)

	set_physics_process(true)


func _physics_process(delta):
	if _path == null or _path.is_empty() or disabled:
		set_physics_process(false)
		return

	var distance = speed * delta
	var last_point = _object.position

	while _path.size():
		var distance_between_points = last_point.distance_to(_path[0])
		var direction = _object.position.direction_to(_path[0])
		check_direction(direction)


		if distance <= distance_between_points:
			_object.position = last_point.lerp(_path[0],distance/distance_between_points)
			return

		distance -= distance_between_points
		last_point = _path[0]
		_path.remove_at(0)

	target_reach.emit()
	_object.position = last_point
	set_physics_process(false)

func check_direction(direction):
	if _direction != direction:
		_direction = direction
		current_direction = direction
		change_direction.emit()
