@tool

extends Node2D

@export var range_color: Color
@export_range(0.0, 1.0) var min_range : set = set_min_range, get = get_min_range
@export_range(0.0, 1.0) var max_range : set = set_max_range, get = get_max_range
@export var mark_multiplier: float
@export var nicole_multiplier: float

var line_length = -90
var line_width = 5
var base_min_range
var base_max_range
var current_min_range
var current_max_range
var debug_in_game = false


func _ready():
	if self.min_range == null:
		self.min_range = 0

	base_min_range = self.min_range
	base_max_range = self.max_range

func set_min_range(value):
	current_min_range = value
	draw_range()


func get_min_range():
	return current_min_range


func set_max_range(value):
	current_max_range = value
	draw_range()


func get_max_range():
	return current_max_range


func draw_range():
	if Engine.is_editor_hint():
		queue_redraw()

	if debug_in_game:
		queue_redraw()


func _draw():
	if Engine.is_editor_hint():
		var from = Vector2(0, current_min_range) * line_length
		var to = Vector2(0, current_max_range) * line_length
		draw_line(from, to, range_color, line_width)

	if debug_in_game:
		var from = Vector2(0, current_min_range) * line_length
		var to = Vector2(0, current_max_range) * line_length
		draw_line(from, to, range_color, line_width)


func move_range(value):
	self.min_range = base_min_range + value
	self.max_range = base_max_range + value

	if self.min_range >= 1:
		self.min_range = 0

	if self.max_range > 1 and (self.max_range - 1) > self.min_range:
		self.max_range -= 1
