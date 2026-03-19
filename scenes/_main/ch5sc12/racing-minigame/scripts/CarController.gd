extends Node3D

class_name CarController

signal velocity_changed(vel)

@export var ghost_mode : bool = false
@export var random_car : bool
@export_enum("Model 1", "Model 2", "Model 3") var car_model : int
@export_enum("Color 1", "Color 2", "Color 3", "Color 4") var color_variation : int
@export var label_text = ""

@onready var ball = $Ball
@onready var car_mesh = $CarMesh
@onready var ground_ray = $CarMesh/RayCast
@onready var car_selector = $CarMesh/CarSelector
@onready var label = $CarMesh/Label3D

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3(0, -1.0, 0)
# Engine power
var acceleration = 80
# Turn amount, in degrees
var steering = 30
# How quickly the car turns
var turn_speed = 3
# Below this speed, the car doesn't turn
var turn_stop_limit = 1

var body_tilt = 35

# Variables for input values
var speed_input = 0
var rotate_input = 0

var can_move = false
var race_started = false
var car


func _ready():
	ground_ray.add_exception(ball)


	if ghost_mode:
		ball.set_collision_mask_value(2, true)
		ball.set_collision_mask_value(1, false)

	if random_car:
		car = car_selector.set_random_car(ghost_mode)
	else:
		car = car_selector.set_car(car_model, color_variation, ghost_mode)

	if label_text.is_empty():
		label.queue_free()
	else:
		label.text = label_text


func start():
	allow_movement(true)
	race_started = true


func accelerate():
	# Keep the car mesh aligned with the sphere
	car_mesh.transform.origin = ball.transform.origin + sphere_offset
	# Accelerate based on car's forward direction
	ball.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)

	velocity_changed.emit(ball.linear_velocity.length())


func rotate_wheels():
	if car != null:
		car.rotate_wheels(rotate_input)


func rotate_car(delta):
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(
			car_mesh.global_transform.basis.y, rotate_input
		)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(
			new_basis, turn_speed * delta
		)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()

		var t = -rotate_input * ball.linear_velocity.length() / body_tilt

		if car != null:
			car.rotate_body(delta, t)


func align_to_surface(delta):
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(car_mesh.global_transform, n.normalized())
	car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10 * delta)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func allow_movement(allow):
	can_move = allow
