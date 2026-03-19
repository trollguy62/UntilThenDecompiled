extends Label

signal countdown_started
signal countdown_finished

@export var max_countdown: int = 3

@onready var timer = $Timer
@onready var ready_node = $Ready
var _count
var _waiting = false


func _ready():
	timer.timeout.connect(_on_timer_timeout)
	hide()


func start_countdown(show_ready = false):
	show()
	ready_node.hide()
	if show_ready:
		ready_node.show()
		await get_tree().create_timer(1.5)
		_waiting = true
		await ready_node.player_ready
		ready_node.hide()
	else:
		_waiting = true
	_count = max_countdown
	text = str(max_countdown)
	countdown_started.emit()
	timer.start()


func _on_timer_timeout():
	_count -= 1
	text = str(_count)
	if _count <= 0:
		timer.stop()
		emit_signal("countdown_finished")
		text = "Mash"
		await get_tree().create_timer(0.5)
		hide()
		ready_node.reset()
		text = ""
		_waiting = false


func mash():
	if not is_visible_in_tree() or not _waiting:
		return
	$Ready.emit_signal("player_ready")
