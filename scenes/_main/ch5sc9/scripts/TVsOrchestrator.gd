extends Node

const TV = preload("TV.gd")

var _tvs = []


func _ready():
	for child in get_children():
		if child is TV:
			_tvs.append(child)


func power_off_all(span: float):
	for tv in _tvs:
		_power_off(tv, randf_range(0, span))


func _power_off(tv: TV, delay: float):
	await Utils.wait(delay)
	tv.tv_power(false)
