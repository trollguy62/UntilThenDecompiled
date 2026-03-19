extends Control

const KaraokeHitTarget = preload("./KaraokeHitTarget.gd")
const LrcScript = preload("../../classes/lrc/LrcScript.gd")

var index = 0
#FIXME: hack
var lines_left: int = 0
#
var timestamp_msec: int = 0:
	set(v):
		for n in get_children():
			if "timestamp_msec" in n:
				n.timestamp_msec = timestamp_msec
		timestamp_msec = v


var lrc_script: LrcScript:
	set(v):
		get_child(index).lrc_script = v
		lines_left += 1
		lrc_script = v


func _ready():
	for c in get_children():
		c.completed.connect(_on_line_completed)
	pass


func spawn(kht: KaraokeHitTarget):
	get_child(index).spawn(kht)


func spawn_hold(hold):
	get_child(index).spawn_hold(hold)


func clear_current():
	get_child(index).clear()


func clear_all():
	for n in get_children():
		if n.has_method("clear"):
			n.clear()
	index = 0


func reset_visibility():
	for n in get_children():
		if n.has_method("reset_visibility"):
			n.reset_visibility()


func get_current_size():
	return get_child(index).size


func move_to_next_line():
	index += 1
	index = index % get_child_count()


func query_progress():
	if _get_active_line():
		return _get_active_line().query_progress()

	return 0


func reset():
	for n in get_children():
		if n.has_method("reset"):
			n.reset()
	index = 0
	self.timestamp_msec = 0
	lines_left = 0


#FIXME: hack
func _get_active_line():
	for c in get_children():
		if c.is_active():
			return c
	return null


func _on_line_completed():
	lines_left -= 1
