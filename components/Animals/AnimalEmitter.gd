extends Node

@export var animal_path: PackedScene
@export var amount : int
@export var min_h_offset: float
@export var max_h_offset: float
@export var min_v_offset: float
@export var max_v_offset: float
@export var random_progress: bool

func _ready():
	for i in amount:
		var animal = animal_path.instantiate()
		animal.h_offset = randf_range(min_h_offset, max_h_offset)
		animal.v_offset = randf_range(min_v_offset, max_v_offset)
		add_child(animal)
		
		if random_progress:
			animal.progress_ratio = randf_range(0, 1)
		


