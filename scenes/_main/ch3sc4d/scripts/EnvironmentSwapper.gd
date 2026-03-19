extends WorldEnvironment

@export var state_key = "lighting"
@export var lighting_env_map := {}  # Map<String, Environment>

@onready var scene_state = Utils.get_state_container_of("scene") as StateContainer


func _ready():
	scene_state.changed.connect(_on_scene_state_changed)
	_on_scene_state_changed()


func _on_scene_state_changed():
	var lighting = scene_state.dict.get_value(state_key)
	environment = lighting_env_map.get(lighting, environment)
