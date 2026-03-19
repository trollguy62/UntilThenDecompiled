extends Area3D

signal entered
signal exited

@export var max_enter_count = -1
@export var max_exit_count = -1

@export var enter_story_signal = ""
@export var enter_short_knot = ""

@export var exit_story_signal = ""
@export var exit_short_knot = ""

@onready var scene_manager = Service.of("SceneManager")

var _is_ready := false

var _enter_count := 0
var _exit_count := 0

var has_entered := false


func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Avoid triggering until after one frame
	await get_tree().process_frame
	_is_ready = true


func _is_active() -> bool:
	return _is_ready and is_visible_in_tree()


func _on_area_entered(area: Area3D):
	if _is_active() and _can_enter_or_exit(true) and _can_enter_from(area):
		_enter_or_exit(true)


func _on_area_exited(area: Area3D):
	if _is_active() and _can_enter_or_exit(false) and _can_exit_from(area):
		_enter_or_exit(false)


func _can_enter_or_exit(enter: bool) -> bool:
	var count = _enter_count if enter else _exit_count
	var max_count = max_enter_count if enter else max_exit_count
	return count < max_count or max_count < 0


func _can_enter_from(area: Area3D) -> bool:
	return true


func _can_exit_from(area: Area3D) -> bool:
	return true


func _enter_or_exit(enter: bool):
	has_entered = enter

	if has_entered:
		_enter_count += 1
		entered.emit()
	else:
		_exit_count += 1
		exited.emit()

	var story_signal = enter_story_signal if has_entered else exit_story_signal
	var short_knot = enter_short_knot if has_entered else exit_short_knot

	if story_signal != "":
		Story.emit(story_signal)

	if short_knot != "" and scene_manager:
		var scene_id = scene_manager.scene_id
		var id = "%s.%s" % [scene_id, short_knot]
		await Story.start_short(id)
