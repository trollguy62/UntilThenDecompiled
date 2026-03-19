extends PathFollow3D

signal lap_completed(current_lap, total_laps)
signal rank_changed(rank)
signal race_finished(p_name)
signal timer_changed(time_passed)
signal time_out(p_name)
signal wrong_way(wrong)
signal event_emitted(ev)
signal velocity_changed(vel)

@export var player_node_path : NodePath
@export var player_name : String

@onready var area = $Area
@onready var player = get_node(player_node_path)
@onready var path: Path3D = get_parent()
@onready var timer: Timer = $Timer

var has_started = false
var total_laps
var current_lap = 0
var current_checkpoint = 0
var checkpoints = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
var time_limit
var current_time = 0
var lap_time_record = []
var has_finished = false
var out = false
var last_posiion = 0.0
var is_wrong_way = false
var start_time = 0
var pause_timer = false


func _ready():
	area.area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)
	player.event_emitted.connect(_on_event_emitted)
	player.velocity_changed.connect(_on_velocity_changed)


func _process(delta):
	if player == null:
		return

	move_path_projector()
	checkpoint()

	if has_started and not out:
		if not has_finished:
			if not pause_timer:
				current_time -= delta
				process_timer()


func move_path_projector():
	var closest_offset = path.curve.get_closest_offset(player.car_mesh.global_transform.origin)

	if current_lap == 0:
		progress = closest_offset
	elif current_lap > 0:
		if (
			closest_offset
			< ((checkpoints[current_checkpoint] + 0.02) * path.curve.get_baked_length())
		):
			progress = closest_offset


func checkpoint():
	if current_checkpoint < (checkpoints.size() - 1):
		if (
			progress_ratio >= (checkpoints[current_checkpoint])
			and progress_ratio < checkpoints[current_checkpoint + 1]
		):
			current_checkpoint += 1

	if current_checkpoint > 0:
		if progress_ratio < checkpoints[current_checkpoint - 1]:
			current_checkpoint -= 1


func set_pause_time(is_paused):
	pause_timer = is_paused


func set_rank(rank):
	rank_changed.emit(rank)


func start_race():
	player.start()
	has_started = true
	start_time = Time.get_ticks_msec()


func set_total_laps(val):
	total_laps = val


func set_time_limit(time):
	time_limit = time
	current_time = time
	process_timer()


func process_timer():
	if current_time <= 0:
		timeout()
		current_time = 0

	var time_passed = time_format_string(current_time)
	timer_changed.emit(time_passed)


func get_race_progress():
	return progress_ratio + current_lap


func finish():
	player.allow_movement(false)
	has_finished = true
	race_finished.emit(player_name)


func complete_lap():
	if current_lap > 0:
		current_time = time_limit
	current_lap += 1
	current_checkpoint = 0
	lap_completed.emit(current_lap,total_laps)


func get_time_finished():
	if out:
		return "X"
	else:
		var total_time = 0
		for lap in lap_time_record:
			total_time += lap

		if not has_finished:
			total_time += time_limit - current_time
			var distance_traveled = get_race_progress() - 1
			var remaining_distance = total_laps - distance_traveled
			var time_to_finished = (total_time * remaining_distance) / distance_traveled
			total_time = total_time + time_to_finished

		return time_format_string(total_time)


func timeout():
	out = true
	player.allow_movement(false)
	time_out.emit(player_name)


func allow_movement(allow):
	player.allow_movement(allow)


func check_wrong_way():
	var current_position = path.curve.get_closest_offset(player.car_mesh.global_transform.origin)
	var dist = current_position - last_posiion

	if not is_wrong_way:
		if dist < -5 and dist > -20:
			is_wrong_way = true
	else:
		if dist > 5 and dist < 20:
			is_wrong_way = false

	last_posiion = current_position
	wrong_way.emit(is_wrong_way)


func _on_timer_timeout():
	check_wrong_way()


func _on_area_entered(area):
	if not has_started:
		return

	if area.name == "FinishLine":
		if (current_checkpoint + 1) == checkpoints.size() or current_lap == 0:
			if current_lap > 0:
				lap_time_record.append(time_limit - current_time)
			if current_lap == total_laps:
				finish()
			else:
				complete_lap()


func _on_event_emitted(ev):
	event_emitted.emit(ev)


func _on_velocity_changed(vel):
	velocity_changed.emit(vel)


func time_format_string(time):
	var mils = fmod(time, 1) * 1000
	var secs = fmod(time, 60)
	var mins = fmod(time, 60 * 60) / 60
	var time_passed = "%02d : %02d : %03d" % [mins, secs, mils]
	return time_passed
