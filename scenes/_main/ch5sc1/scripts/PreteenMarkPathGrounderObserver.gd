extends Node

const PathGrounder = preload("res://components/PathGrounder.gd")

@export var enabled := false

@onready var path_grounder = get_parent() as PathGrounder
@onready var timer = $Timer

var _skit_container: SkitContainer
var _pending_short_completion := false
var _timeout_short_knot := ""


func _ready():
	assert(path_grounder is PathGrounder)
	timer.timeout.connect(_on_timer_timeout)


func _process(delta):
	if not _is_active():
		return

	if path_grounder.delta_offset < 0:
		_start_timer("Dream_exchange_backward", randf_range(1, 3))
	else:
		_start_timer("Dream_exchange_forward", randf_range(4, 8))


func _is_active() -> bool:
	return enabled and _skit_container != null and not _pending_short_completion


func _start_timer(knot: String, time_sec: float):
	if _timeout_short_knot != knot:
		_timeout_short_knot = knot
		timer.start(time_sec)


func _on_timer_timeout():
	if _is_active():
		_start_short(_timeout_short_knot)
		_timeout_short_knot = ""


func _start_short(knot: String):
	_pending_short_completion = true
	await _skit_container.start_short(knot)
	_pending_short_completion = false


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container
	skit_container.skit_finished.connect(_on_skit_finished)


func _on_skit_finished():
	_skit_container = null


func _run_command(cmd: Command):
	match cmd.name:
		"set_observe_walking":
			enabled = bool(cmd.params[0])
		_:
			return Constants.CMD_RETURN_NONE

	return null
