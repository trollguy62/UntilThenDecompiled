extends Node3D

@export var emitting = false
@export_range(0, 8) var max_vehicle_count = 1
@export var vehicles: Array[PackedScene]

@export var direction = Vector3.LEFT
@export var distance = 10.0
@export var min_velocity = 5.0
@export var max_velocity = 10.0

@export var min_interval = 1.0
@export var max_interval = 2.0

@onready var timer = Timer.new()

var _emitted_vehicles = {}  # Map<String (child node name), float (velocity factor)>
var _skit_container: SkitContainer


func _ready():
	timer.one_shot = true
	add_child(timer)

	timer.timeout.connect(_on_timer_timeout)
	_on_timer_timeout()


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container


func _process(delta):
	for child_name in _emitted_vehicles.keys():
		var vehicle = get_node(child_name)

		if vehicle.transform.origin.length() > distance:
			vehicle.queue_free()
			_emitted_vehicles.erase(child_name)
			continue

		var velocity = lerp(min_velocity, max_velocity, _emitted_vehicles[child_name])
		vehicle.translate(direction * velocity * delta)


func _on_timer_timeout():
	var skit_active = (
		Engine.is_editor_hint()
		or (is_instance_valid(_skit_container) and _skit_container.is_running)
	)

	if emitting and _emitted_vehicles.size() < max_vehicle_count and skit_active:
		emit()

	timer.start(randf_range(min_interval, max_interval))


func emit():
	if vehicles.is_empty():
		return

	var vehicle_scene = vehicles[randi() % vehicles.size()]
	var vehicle_inst = vehicle_scene.instantiate()
	vehicle_inst.transform = Transform3D.IDENTITY

	add_child(vehicle_inst)
	_emitted_vehicles[vehicle_inst.name] = randf()
