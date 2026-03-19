extends Node

@export var visible_on_shots: Array[String] = []
@export var invert = false

@onready var parent = get_parent()
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

	scene_manager.shot_changed.connect(func(_s):
		# We don't update visibility immediately since it causes some split-second artifact
		# This seems to work better than `call_deferred`
		await get_tree().process_frame
		_update()
	)
	_update()


func _update():
	var is_visible = scene_manager.shot in visible_on_shots
	if invert:
		is_visible = not is_visible
	parent.visible = is_visible
