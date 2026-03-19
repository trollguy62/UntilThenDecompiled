class_name Recording
extends Resource

@export var name: String
@export var duration_secs := 0.0
@export var manual_count := 0

@export var input_event_records := []
@export var mouse_position_records := []

var ier_idx := 0
var mpr_idx := 0


func process_records(cur_time: float, delta: float, window_size: Vector2):
	var flush_buffer := false

	while ier_idx < input_event_records.size():
		var record: InputEventRecord = input_event_records[ier_idx]

		if record.time <= cur_time:
			# TODO: Mouse clicks in a non-default resolution must be scaled accordingly
			Input.parse_input_event(record.event)
			ier_idx += 1
			flush_buffer = true
		else:
			break

	while mpr_idx < mouse_position_records.size():
		var record: MousePositionRecord = mouse_position_records[mpr_idx]

		if record.time <= cur_time:
			Input.warp_mouse(record.unit_position * window_size)
			mpr_idx += 1
			flush_buffer = true
		else:
			break

	if flush_buffer:
		Input.flush_buffered_events()
