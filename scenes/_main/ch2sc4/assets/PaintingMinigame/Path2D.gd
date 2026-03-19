extends Path2D

signal finished

const FINISH_TOLERANCE = 0.004

@export var break_distance = 160.0
@export var max_allowable_jump_px = 500.0
@export var chase_multiplier = 12.0
@export var max_size = 25.0
@export var base_color: Color = Color("2f559750")
@export var focus_color: Color = Color("2f5597a0")
@export var break_color: Color = Color("ff000080")

@onready var target = $Target
@onready var p_follow = $PathFollow2D


var _dist = 0.0
var enabled = false:
	set(v):
		if not enabled and v:
			p_follow.progress = 0
			target.position = curve.get_point_position(0)
		enabled = v

func _process(delta):
	_dist = target.position.distance_to(curve.get_closest_point(target.position))
	if enabled:
		var diff = curve.get_closest_point(target.position) - curve.get_point_position(curve.point_count - 1)
		var _offset_to_travel = curve.get_closest_offset(target.position) - p_follow.progress
		if abs(_offset_to_travel) < max_allowable_jump_px:
			p_follow.progress += chase_multiplier * _offset_to_travel * delta
			p_follow.progress_ratio = clamp(p_follow.progress_ratio, 0, 1.0,)

		if diff.length_squared() < FINISH_TOLERANCE:
			finish()

	queue_redraw()

func _draw():
	if enabled:
		if _dist < break_distance:
			#print(curve.get_closest_offset(target.position))
			#draw_line(target.position, curve.get_closest_point(target.position), lerp(Color.AQUA, Color.CRIMSON, _dist/break_distance), 5.0)
			var color = lerp(focus_color, break_color, _dist/break_distance)
			var size = lerp(max_size, 0.0, _dist/break_distance)
			draw_circle(curve.get_closest_point(target.position), size, color)
		else:
			reset()

		for pt in curve.point_count:
			#print(curve.get_point_position(pt))
			draw_circle(curve.get_point_position(pt), 5.0, Color.CORAL)
	else:
		draw_circle(curve.get_point_position(0), 25.0, base_color)

func finish():
	p_follow.progress_ratio = 1.0
	enabled = false
	finished.emit()

func reset():
	p_follow.progress = 0.0
	enabled = false
