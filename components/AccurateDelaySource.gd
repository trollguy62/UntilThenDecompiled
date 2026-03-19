var pause_mode_process: bool
var _remainder := 0.0

var _waiting := false
var _pause_dt_rec := DeltaTimeRecorder.new()
var _pause_t := 0.0


func _init(pause_mode_process: bool = false):
	self.pause_mode_process = pause_mode_process
	Game.paused_changed.connect(_on_game_paused_changed)


func delay(duration: float):
	if duration <= 0:
		return

	var t = duration - _remainder
	_remainder = max(0, _remainder - duration)

	if t > 0:
		var dt_rec = DeltaTimeRecorder.new()
		dt_rec.start()

		_waiting = true
		_pause_t = 0
		_update_pause_t()

		await Utils.wait(t, pause_mode_process)

		_waiting = false
		_update_pause_t()

		var elapsed = dt_rec.end()
		if not pause_mode_process:
			elapsed = max(0, elapsed - _pause_t)

		_remainder += elapsed - t


func _on_game_paused_changed(_paused: bool):
	_update_pause_t()


func _update_pause_t():
	if Game.paused and _waiting:
		_pause_dt_rec.start()
	elif _pause_dt_rec.is_recording():
		_pause_t += _pause_dt_rec.end()


class DeltaTimeRecorder:
	var t0 := 0.0

	func start():
		t0 = Time.get_ticks_msec()

	func end() -> float:
		var t1 = Time.get_ticks_msec()
		var dt = (t1 - t0) / 1000.0
		t0 = 0.0

		return dt

	func is_recording():
		return t0 > 0.0
