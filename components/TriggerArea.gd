extends Area3D

signal triggered

@export var max_trigger_count = -1
@export var story_signal = ""
@export var short_knot = ""

@onready var scene_manager = Service.of("SceneManager")

var _is_ready := false
var _trigger_count := 0


func _ready():
	area_entered.connect(_on_area_entered)
	# Avoid triggering until after one frame
	await get_tree().process_frame
	_is_ready = true


func _on_area_entered(area: Area3D):
	if not (_is_ready and is_visible_in_tree()):
		return

	var can_trigger = _trigger_count < max_trigger_count or max_trigger_count < 0
	if can_trigger and _can_trigger_from(area):
		_trigger()


func _can_trigger_from(area: Area3D) -> bool:
	return true


func _trigger():
	_trigger_count += 1
	triggered.emit()

	if story_signal != "":
		Story.emit(story_signal)

	if short_knot != "" and scene_manager:
		var scene_id = scene_manager.scene_id
		var id = "%s.%s" % [scene_id, short_knot]
		await Story.start_short(id)
