extends "res://components/TriggerArea.gd"


func _can_trigger_from(area: Area3D) -> bool:
	return area.global_transform.origin.z < global_transform.origin.z
