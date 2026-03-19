extends "res://components/TriggerArea.gd"

const SHORT_ID = "lo.1.1b.no_ticket"

@onready var scene_state = Service.of("SceneState")
@onready var player_target = Service.of("PlayerTarget")


func _trigger():
	super._trigger()

	var has_ticket = scene_state.dict.get_value("has_ticket", false)
	if not has_ticket:
		await Story.start_short(SHORT_ID)
		player_target.change($Target)
