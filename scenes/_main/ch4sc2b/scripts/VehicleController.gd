extends Node

@export var min_interval : float
@export var max_interval : float
@export var enabled = true
@onready var timer = Timer.new()

var vehicles = []



func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _ready():	
	vehicles = get_children()
	disable_all_vehicles()		
	
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	start_timer()


func start_timer():
	var interval = randf_range(min_interval,max_interval)
	timer.start(interval)
	timer.one_shot = true	


func disable_all_vehicles():
	for vehicle in vehicles:
		vehicle.visible = false
		vehicle.stop()


func enable_vehicle():
	if not enabled:
		return
	
	start_timer()	
	var i = randi_range(0,vehicles.size()-1)

	if vehicles[i].is_moving:
		return
	
	vehicles[i].visible = true
	vehicles[i].move()



func _on_timer_timeout():
	enable_vehicle()


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"enable_vehicle":
			enabled = params[0]
			if not enabled:
				disable_all_vehicles()
				
		"set_vehicle_intervals":
			min_interval = params[0]
			max_interval = params[1]
		_:
			return Constants.CMD_RETURN_NONE

	return null
