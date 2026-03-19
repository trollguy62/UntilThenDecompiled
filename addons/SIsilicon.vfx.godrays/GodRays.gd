@tool
extends Node3D

var light: Light3D

@export_range(0.0, 2.0) var exposure := 0.5:
	set(value):
		exposure = value
		material.set_shader_parameter("exposure", exposure)
		if canvas:
			canvas.visible = exposure != 0

@export_exp_easing var attenuation := 2.0:
	set(value):
		attenuation = value
		material.set_shader_parameter("attenuate", attenuation)
		if canvas:
			canvas.visible = attenuation != 0

@export_range(0.0, 2.0) var light_size := 0.5:
	set(value):
		light_size = value
		if canvas:
			canvas.visible = light_size != 0

var clouds: Texture:
	set(value):
		clouds = value
		material.set_shader_parameter("clouds", value)
		material.set_shader_parameter("use_clouds", value != null)

var canvas: MeshInstance3D
var material := preload("GodRays.tres").duplicate() as ShaderMaterial


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		if get_parent() is Light3D:
			light = get_parent()
	elif what == NOTIFICATION_UNPARENTED:
		light = null
		clouds = null


func _ready() -> void:
	if get_child_count() > 0 and get_child(0).owner == null:
		remove_child(get_child(0))

	var mesh := QuadMesh.new()
	mesh.size = Vector2(2, 2)
	mesh.custom_aabb = AABB(Vector3(1, 1, 1) * -300000, Vector3(1, 1, 1) * 600000)

	canvas = MeshInstance3D.new()
	canvas.name = "GodRay"
	canvas.mesh = mesh
	canvas.material_override = material
	add_child(canvas)

	material.setup_local_to_scene()

	self.exposure = exposure
	self.attenuation = attenuation
	self.light_size = light_size

	self.clouds = null


func _process(delta: float) -> void:
	var num_samples = ProjectSettings.get_setting("rendering/quality/godrays/sample_number")
	canvas.visible = num_samples > 0

	if light == null:
		material.set_shader_parameter("light_type", 0)
		material.set_shader_parameter("light_pos", Vector3())
		return

	var is_directional := light is DirectionalLight3D

	material.set_shader_parameter("light_type", not is_directional)
	material.set_shader_parameter("light_color", light.light_color * light.light_energy)

	if is_directional:
		var direction := light.global_transform.basis.z
		material.set_shader_parameter("light_pos", direction)
		material.set_shader_parameter("size", light_size)
	else:
		var position := light.global_transform.origin
		var size := light_size

		if light is OmniLight3D:
			size *= light.omni_range
		elif light is SpotLight3D:
			size *= light.spot_range

		material.set_shader_parameter("light_pos", position)
		material.set_shader_parameter("size", size)

	material.set_shader_parameter("num_samples", num_samples)
	material.set_shader_parameter(
		"use_pcf5", ProjectSettings.get_setting("rendering/quality/godrays/use_pcf5")
	)
	material.set_shader_parameter(
		"dither", ProjectSettings.get_setting("rendering/quality/godrays/dither_amount")
	)
