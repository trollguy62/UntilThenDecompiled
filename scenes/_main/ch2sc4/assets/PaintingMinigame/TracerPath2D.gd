extends Path2D

signal finished

const FINISH_TOLERANCE = 0.004
const SFX_THRESHOLD_PX = 0

@export var break_distance = 160.0
@export var max_allowable_jump_px = 500.0
@export var chase_multiplier = 12.0
@export var max_size = 13.0
@export var base_color: Color = Color("2f559750")
@export var focus_color: Color = Color("2f5597a0")
@export var break_color: Color = Color("ff000080")

@onready var target = $Target
@onready var p_follow = $PathFollow2D
@onready var offset_marker = $PathFollow2D/Marker2D
@onready var sfx = $Stroke
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

			#audio
			if abs(_offset_to_travel) > SFX_THRESHOLD_PX and not sfx.playing:
				sfx.play(randf_range(0.0, sfx.stream.get_length()))
			else:
				get_tree().create_timer(0.75).timeout.connect(sfx.stop)
			#

		if diff.length_squared() < FINISH_TOLERANCE:
			finish()

	queue_redraw()

func _draw():
	if enabled:
		if _dist < break_distance:

			var color = lerp(focus_color, break_color, _dist/break_distance)
			var size = lerp(max_size, 0.0, _dist/break_distance)

			draw_circle(to_local(offset_marker.global_position), size, color)
		else:
			reset()
	else:
		draw_circle(curve.get_point_position(0), 8, base_color)

func finish():
	p_follow.progress_ratio = 1.0
	enabled = false
	finished.emit()

func reset():
	var t = get_tree().create_tween()
	t.tween_property(p_follow, "progress", 0.0, 0.4)
	enabled = false
