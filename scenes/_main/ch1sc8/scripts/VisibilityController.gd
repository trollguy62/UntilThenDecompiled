extends Node

const PART_KEY = &"part"

@export var visible_on_shots: Array[String]= []
@export var visible_on_parts: Array[String] = []
@export var not_visible_on_shots: Array[String] = []
@export var not_visible_on_parts: Array[String] = []

@onready var scene_manager = Service.of("SceneManager") as SceneManager
@onready var scene_state = Service.of("SceneState") as StateContainer


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

	scene_manager.shot_changed.connect(func(_s): _update_deferred())
	scene_state.dict.changed.connect(func(key, _a, _b):
		if key == PART_KEY:
			_update_deferred()
	)

	_update()


func _update_deferred():
	await get_tree().process_frame
	_update()


func _update():
	var shot = scene_manager.shot
	var part = scene_state.dict.get_value(PART_KEY, "")

	var is_visible = (
		(shot in visible_on_shots or visible_on_shots.is_empty())
		and (part in visible_on_parts or visible_on_parts.is_empty())
		and not shot in not_visible_on_shots
		and not part in not_visible_on_parts
	)
	get_parent().visible = is_visible
