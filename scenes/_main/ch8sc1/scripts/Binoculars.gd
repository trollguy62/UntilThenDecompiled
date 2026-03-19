extends Node2D

const PAN_SPEED = 60.0
const MOUSE_MOVEMENT_THRESHOLD = 4

@onready var sprite = $Vista

var offset_min_x = -90
var offset_max_x = 90
var offset_min_y = -30
var offset_max_y = 30
var starting_pos

func _ready():
	starting_pos =  Vector2(640,360)
	sprite.position = starting_pos

func _process(delta):
	if not is_visible_in_tree():
		return

	var input_vector = _get_input()
	var _offset = sprite.offset

	#flip axis to match visual
	input_vector.x = -input_vector.x

	_offset += input_vector * delta * PAN_SPEED
	_offset = Vector2(clamp(_offset.x, offset_min_x, offset_max_x),clamp(_offset.y,offset_min_y,offset_max_y))

	sprite.offset = _offset

func _get_input():
	return Input.get_vector("move_left", "move_right", "move_down", "move_up")

func _input(event):
	if event is InputEventMouseMotion:
		if event.relative.length_squared() >= MOUSE_MOVEMENT_THRESHOLD:
			var _offset = starting_pos - get_viewport().get_mouse_position()
			_offset = _offset/4
			_offset = Vector2(clamp(_offset.x, offset_min_x, offset_max_x),clamp(_offset.y,offset_min_y,offset_max_y))
			sprite.offset = _offset
