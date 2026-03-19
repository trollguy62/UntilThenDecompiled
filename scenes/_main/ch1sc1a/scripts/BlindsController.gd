extends Node

@onready var state = Service.of("SceneState") as StateContainer
@onready var blinds_up = $"../BlindsUp"
@onready var blinds_down = $"../BlindsDown"


func _process(delta):
	var up = state.dict.get_value("part", 0) >= 3
	blinds_up.visible = up
	blinds_down.visible = not up
