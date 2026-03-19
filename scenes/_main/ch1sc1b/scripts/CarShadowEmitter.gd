extends Node3D

@onready var timer := Timer.new()

@export var textures: Array[Texture] = []
@export var interval_mean := 4.0
@export var interval_sd := 0.5
@export var max_distance := 50.0
@export var min_z_offset := 0.0
@export var max_z_offset := 0.5

var _cars := []


func _ready():
	timer.timeout.connect(emit)
	timer.one_shot = true
	add_child(timer)
	schedule_emit()


func _process(delta):
	var free_list = []

	for car in _cars:
		car.transform.origin += Vector3.LEFT * 5.0 * delta
		var dist = car.global_transform.origin.distance_to(global_transform.origin)

		if dist >= max_distance:
			free_list.append(car)

	for car in free_list:
		_cars.erase(car)
		remove_child(car)
		car.queue_free()


func schedule_emit():
	timer.start(randfn(interval_mean,interval_sd))
	pass


func emit():
	var car = Paper3D.new()
	car.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	car.texture = textures[randi() % textures.size()]
	car.transform.origin.z += randf_range(min_z_offset, max_z_offset)

	add_child(car)
	_cars.append(car)
	schedule_emit()
