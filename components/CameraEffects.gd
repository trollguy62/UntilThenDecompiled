@tool
extends Node
class_name CameraEffects

signal value_changed()

@export_group("DOF Blur")
@export var dof_blur_far_enabled := false:
	set(value):
		dof_blur_far_enabled = value
		value_changed.emit()

@export_range(0.01, 8192) var dof_blur_far_distance = 10.0:
	set(value):
		dof_blur_far_distance = value
		value_changed.emit()

@export_range(-1.0, 8192) var dof_blur_far_transition = 5.0:
	set(value):
		dof_blur_far_transition = value
		value_changed.emit()

@export_range(0, 1) var dof_blur_far_amount = 0.1:
	set(value):
		dof_blur_far_amount = value
		value_changed.emit()

@export var dof_blur_near_enabled := false:
	set(value):
		dof_blur_near_enabled = value
		value_changed.emit()

@export_range(0.01, 8192) var dof_blur_near_distance = 2.0:
	set(value):
		dof_blur_near_distance = value
		value_changed.emit()

@export_range(-1.0, 8192) var dof_blur_near_transition = 0.1:
	set(value):
		dof_blur_near_transition = value
		value_changed.emit()

@export_range(0, 1) var dof_blur_near_amount = 0.1:
	set(value):
		dof_blur_near_amount = value
		value_changed.emit()


@export_group("Auto Exposure")
@export_range(0,64000) var auto_exposure_min_sensitivity = 800.0:
	set(value):
		auto_exposure_min_sensitivity = value
		value_changed.emit()

@export_range(0,64000) var auto_exposure_max_sensitivity = 800.0:
	set(value):
		auto_exposure_max_sensitivity = value
		value_changed.emit()

@export var auto_exposure_enabled := false:
	set(value):
		auto_exposure_enabled = value
		value_changed.emit()

@export_range(0.01,64) var auto_exposure_scale = 0.4:
	set(value):
		auto_exposure_scale = value
		value_changed.emit()

@export_range(0.01,64) var auto_exposure_speed = 0.5:
	set(value):
		auto_exposure_speed = value
		value_changed.emit()

@export_group("Exposure")
@export_range(0,2048) var exposure_multiplier = 1.0:
	set(value):
		exposure_multiplier = value
		value_changed.emit()

@onready var camera = get_parent() as Camera3D


func _ready():
	value_changed.connect(update_camera_attributes)
	update_camera_attributes()


func update_camera_attributes():
	if camera == null:
		return

	if camera.attributes == null:
		camera.attributes = CameraAttributesPractical.new()

	camera.attributes.dof_blur_far_enabled = dof_blur_far_enabled
	camera.attributes.dof_blur_far_distance = dof_blur_far_distance
	camera.attributes.dof_blur_far_transition = dof_blur_far_transition

	camera.attributes.dof_blur_near_enabled = dof_blur_near_enabled
	camera.attributes.dof_blur_near_distance = dof_blur_near_distance
	camera.attributes.dof_blur_near_transition = dof_blur_near_transition

	camera.attributes.dof_blur_amount = _mean_nonzero(
			dof_blur_far_amount * float(dof_blur_far_enabled),
			dof_blur_near_amount * float(dof_blur_near_enabled))

	camera.attributes.auto_exposure_enabled = auto_exposure_enabled
	camera.attributes.auto_exposure_scale = auto_exposure_scale
	camera.attributes.auto_exposure_speed = auto_exposure_speed
	camera.attributes.exposure_multiplier = exposure_multiplier


func _mean_nonzero(a: float, b: float) -> float:
	var sum = a + b
	var d = 0

	if a >= Constants.EPSILON:
		d += 1
	if b >= Constants.EPSILON:
		d += 1

	if d == 0:
		return 0

	return sum / d
