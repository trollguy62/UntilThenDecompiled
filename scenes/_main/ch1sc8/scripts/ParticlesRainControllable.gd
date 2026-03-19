@tool
extends "RainControllable.gd"

var _amount := 0
var _is_ready := false

@export var follow_camera: bool = false

@onready var timer = Timer.new()


func _ready():
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)

	_is_ready = true
	_amount = call("get_amount")
	set_particle_amount(_amount)

func _process(delta):
	if Engine.is_editor_hint():
		return

	if follow_camera:
		var cam_pos = get_viewport().get_camera_3d().global_position
		if "global_position" in self:
			cam_pos.y = self.global_position.y
			self.global_position = cam_pos


func _on_timeout():
	self.intensity = intensity


func _set(property: StringName, value) -> bool:
	if _is_ready and property == "amount" and value is int:
		set_particle_amount(value)
		return true

	return false


func set_particle_amount(amount: int):
	_amount = amount
	call("set_emitting", intensity > 0)

	if timer.time_left == 0:
		var rel_amount = _amount * intensity
		call("set_amount", max(1, rel_amount))
		timer.start(1)


func _set_intensity(value):
	if intensity != value:
		intensity = value
		if _ready:
			set_particle_amount(_amount)
