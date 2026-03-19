extends Node

@export var event_asset: EventAsset

@onready var light = get_parent() as Light3D

var _last_light_energy := 0.0


func _process(delta):
	var energy = light.light_energy

	if abs(_last_light_energy - energy) > Constants.EPSILON and energy < Constants.EPSILON:
		FMODRuntime.play_one_shot_attached(event_asset, light)

	_last_light_energy = energy
