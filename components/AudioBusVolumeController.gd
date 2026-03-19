extends Node

@export var audio_bus_name: String:
	set(value):
		audio_bus_name = value
		_bus_idx = AudioServer.get_bus_index(audio_bus_name)

@export_range(0, 1) var volume: float = 1

var _bus_idx := -1


func _process(delta):
	_set_volume(volume)


func _exit_tree():
	_set_volume(1.0)


func _set_volume(volume: float):
	var real_vol = volume * _get_volume_multiplier()
	AudioServer.set_bus_volume_db(_bus_idx, linear_to_db(real_vol))


func _get_volume_multiplier() -> float:
	match audio_bus_name:
		"Music":
			return Game.config.music_vol
		"SFX":
			return Game.config.sfx_vol
		_:
			return 1.0
