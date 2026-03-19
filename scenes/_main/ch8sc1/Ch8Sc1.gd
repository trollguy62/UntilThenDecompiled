extends Scene

@onready var world_environment = $WorldEnvironment
@onready var hillstop = $World/Hillstop

@onready var scene_state = Utils.get_state_container_of("scene") as StateContainer


func _ready():
	super._ready()
	scene_state.changed.connect(_on_scene_state_changed)
	_on_scene_state_changed()


func _on_scene_state_changed():
	var lighting = scene_state.dict.get_value(world_environment.state_key)
	hillstop.light_energy = 1 if lighting == "dusk" else 0
