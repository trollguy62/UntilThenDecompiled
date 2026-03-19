extends Scene

@onready var scene_state = $"Main/$SceneState"
@onready var cathy_state = $Characters/CathyPortillo/State


func _ready():
	super._ready()
	cathy_state.dict.changed.connect(_on_cathy_state_dict_changed)
	scene_state.dict.set_value("cathy_path_mode", false)


func _on_cathy_state_dict_changed(key: String, old_value, value):
	if key == "path_mode":
		scene_state.dict.set_value("cathy_path_mode", value)
