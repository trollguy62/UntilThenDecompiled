extends Resource

const Keybind = preload("res://data/Keybind.gd")

@export var version: int = 1
@export var keybinds: Array[Keybind] = []

func _init(_keybinds = keybinds):
	keybinds = _keybinds
