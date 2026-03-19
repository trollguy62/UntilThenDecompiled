extends Node

@export var opaque_mat : Resource
@export var transparent_mat : Resource
@onready var car_models = get_children()


func set_car(model_no, variation_no, ghost_mode):
	reset()
	var mat = transparent_mat if ghost_mode else opaque_mat
	car_models[model_no].visible = true
	car_models[model_no].set_variation(variation_no, mat.duplicate())

	return car_models[model_no]


func set_random_car(ghost_mode):
	if randi() % 1000 == 1:
		return set_car(3, 0, ghost_mode)
	else:
		var random_model = randi() % car_models.size()
		var random_variation = car_models[random_model].get_random_variation()
		return set_car(random_model, random_variation, ghost_mode)


func reset():
	for car in car_models:
		car.visible = false
