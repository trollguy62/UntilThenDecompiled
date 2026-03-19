extends CarController

signal event_emitted(ev)

@export var replay_data : Resource

var events = []
var position_data = []
var rotation_data = []
var frames = 0
var time = 0
var current_pos
var previous_pos
var velocity
var inited = false


func _ready():
	super._ready()
	var r = load(replay_data.resource_path)
	events = r.events.duplicate()
	position_data = r.position_data.duplicate()
	rotation_data = r.rotation_data.duplicate()
	current_pos = car_mesh.transform.origin
	previous_pos = current_pos

	for ev in events:
		ev["emitted"] = false
	inited = true


func _process(delta):
	process_transform()
	process_events(delta)


func _physics_process(delta):
	if can_move:
		frames += 1
		simulate_velocity(delta)


func simulate_velocity(delta):
	current_pos = car_mesh.transform.origin
	velocity = (previous_pos - current_pos).length() / delta
	previous_pos = current_pos
	velocity_changed.emit(velocity)


func process_transform():
	if inited == false:
		return
	if frames < position_data.size():
		car_mesh.transform.origin = position_data[frames]
		car_mesh.global_transform = rotation_data[frames]


func process_events(delta):
	if not can_move:
		return

	time += delta
	for ev in events:
		if time >= ev.timestamp and not ev.emitted:
			ev.emitted = true
			event_emitted.emit(ev["signal"]) # ev.signal
