extends "WebPage.gd"


func load(speed_mult: float = 1):
	await get_tree().process_frame
	visible = false
	progress = 0.2
	is_loading = true

	timer.timeout.connect(cancel)
	timer.start(randf_range(0.2, 0.6))


func cancel():
	visible = true
	progress = 1
	is_loading = false

	if timer.timeout.is_connected(cancel):
		timer.timeout.disconnect(cancel)

	loaded.emit()


func _get_progress():
	return progress


func _is_loading():
	return is_loading
