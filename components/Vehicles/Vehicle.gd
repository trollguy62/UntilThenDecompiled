extends Node3D

@export var min_speed : float = 1
@export var max_speed : float = 2

@onready var path_grounder = $PathGrounder
@onready var event = Utils.get_child_of_type(self, "StudioEventEmitter3D")

var is_moving  = false


func _ready():
	visible = false


func _process(delta):
	if is_moving and path_grounder.path_unit_offset >=1:
		stop()


func move():
	var speed = randf_range(min_speed,max_speed)
	path_grounder.offset_speed = speed
	path_grounder.enabled = true
	path_grounder.path_unit_offset = 0
	is_moving = true
	visible = true

	if event:
		event.play()


func stop():
	path_grounder.enabled = false
	is_moving = false
	visible = false

	if event:
		event.stop()
