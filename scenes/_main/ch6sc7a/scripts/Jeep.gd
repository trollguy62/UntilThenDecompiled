extends MeshInstance3D

@export var rotation_speed = -2.0

var wheels = []


func _ready():
	for i in $Wheels.get_children():
		wheels.append(i)


func _process(delta):
	for wheel in wheels:
		wheel.rotate_z(rotation_speed * delta)
