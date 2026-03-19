extends "res://components/TriggerArea.gd"

@onready var player_target = Service.of("PlayerTarget")


func _can_trigger_from(area: Area3D) -> bool:
	return area.global_transform.origin.x < global_transform.origin.x


func _trigger():
	await super._trigger()
	player_target.change($Target)
