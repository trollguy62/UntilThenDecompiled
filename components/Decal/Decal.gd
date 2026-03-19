# Derived from source: https://github.com/Master-J/DecalCo
@tool
extends MeshInstance3D
class_name CustomDecal

const DECAL_SHADER: Resource = preload("res://assets/shaders/Decal.gdshader")

enum PlaybackType { LOOP, ONE_SHOT }

@export_range(0.0, 1.0) var pixel_size: float = 0.0

@export var albedo: Texture:
	set(value):
		albedo = value
		decal_material.set_shader_parameter("albedo", albedo)

		var ps = pixel_size if pixel_size > 0 else 0.01
		var tex_size = albedo.get_size() * ps
		scale = Vector3(tex_size.x, tex_size.y, scale.z)

@export var albedo_tint: Color = Color.WHITE:
	set(value):
		albedo_tint = value
		decal_material.set_shader_parameter("albedo_tint", albedo_tint)

@export var emission: Texture:
	set(value):
		emission = value
		decal_material.set_shader_parameter("emission", emission)

@export var emission_tint: Color = Color.BLACK:
	set(value):
		emission_tint = value
		decal_material.set_shader_parameter("emission_tint", emission_tint)
		decal_material.set_shader_parameter("specular", specular)

@export_range(0.0, 10.0) var emission_strength: float:
	set(value):
		emission_strength = value
		decal_material.set_shader_parameter("emission_strength", emission_strength)

@export var normal_map: Texture:
	set(value):
		normal_map = value
		decal_material.set_shader_parameter("normal_map", normal_map)

@export_range(0.0, 64.0) var normal_map_depth: float = 1.0:
	set(value):
		normal_map_depth = value
		decal_material.set_shader_parameter("normal_map_depth", normal_map_depth)

@export var normal_linear_sampling: bool:
	set(value):
		normal_linear_sampling = value
		decal_material.set_shader_parameter("normal_linear_sampling", normal_linear_sampling)

@export var occlusion: Texture:
	set(value):
		occlusion = value
		decal_material.set_shader_parameter("occlusion", occlusion)

@export_range(0.0, 1.0) var occlusion_strength: float:
	set(value):
		occlusion_strength = value
		decal_material.set_shader_parameter("occlusion_strength", occlusion_strength)

@export var specular: Texture:
	set(value):
		specular = value

@export_range(0.0, 1.0) var specular_strength: float :
	set(value):
		specular_strength = value
		decal_material.set_shader_parameter("specular_strength", specular_strength)

@export var flipbook_playback_type: PlaybackType = PlaybackType.LOOP
@export var flipbook_current_frame: int = 0:
	set(value):
		flipbook_current_frame = value

		if flipbook_current_frame >= flipbook_columns_count * flipbook_columns_count:
			flipbook_current_frame = 0
		elif flipbook_current_frame < 0:
			flipbook_current_frame = (flipbook_columns_count * flipbook_columns_count) - 1

		decal_material.set_shader_parameter("current_frame", flipbook_current_frame)

@export var flipbook_columns_count: int = 1:
	set(value):
		flipbook_columns_count = max(value, 1)
		decal_material.set_shader_parameter("flipbook_columns_count", flipbook_columns_count)

@export var flipbook_fps: int = 1
@export var flipbook_play: bool = false

var _use_normal_map := false
var _clock := 0.0
var decal_material: Material = null


func _init():
	_setup()


func _setup():
	# Instantiate the decal's projector mesh and its decal material
	mesh = BoxMesh.new()
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	decal_material = ShaderMaterial.new()
	decal_material.shader = DECAL_SHADER

	set("material/0", decal_material)
	# Needed in order to make the decal render behind transparent geometry
	decal_material.render_priority = -1


func _ready():
	if Engine.is_editor_hint():
		_setup()  # Allows for duplication

	decal_material.set_shader_parameter("albedo", albedo)
	decal_material.set_shader_parameter("albedo_tint", albedo_tint)
	decal_material.set_shader_parameter("emission", emission)
	decal_material.set_shader_parameter("emission_tint", emission_tint)
	decal_material.set_shader_parameter("normal_map", normal_map)
	decal_material.set_shader_parameter("normal_linear_sampling", normal_linear_sampling)
	decal_material.set_shader_parameter("occlusion", occlusion)
	decal_material.set_shader_parameter("specular", specular)
	decal_material.set_shader_parameter("use_normal_map", _use_normal_map)
	decal_material.set_shader_parameter("emission_strength", emission_strength)
	decal_material.set_shader_parameter("occlusion_strength", occlusion_strength)
	decal_material.set_shader_parameter("specular_strength", specular_strength)
	decal_material.set_shader_parameter("current_frame", flipbook_current_frame)
	decal_material.set_shader_parameter("flipbook_columns_count", flipbook_columns_count)
	decal_material.set_shader_parameter("decal_position", global_transform.origin)
	decal_material.set_shader_parameter("decal_right", global_transform.basis.x.normalized())
	decal_material.set_shader_parameter("decal_up", global_transform.basis.y.normalized())
	decal_material.set_shader_parameter("decal_forward", -global_transform.basis.z.normalized())
	decal_material.set_shader_parameter("decal_half_scale", scale / 2.0)

func set_flipbook_play(new_flipbook_play: bool):
	if new_flipbook_play:
		flipbook_play = true
		flipbook_current_frame = 0
	else:
		flipbook_play = false


func _process(delta: float):
	decal_material.set_shader_parameter("decal_position", global_transform.origin)
	decal_material.set_shader_parameter("decal_right", global_transform.basis.x.normalized())
	decal_material.set_shader_parameter("decal_up", global_transform.basis.z.normalized())
	decal_material.set_shader_parameter("decal_forward", global_transform.basis.y.normalized())
	decal_material.set_shader_parameter("decal_half_scale", global_transform.basis.get_scale() / 2.0)

	if normal_map == null:
		decal_material.set_shader_parameter("use_normal_map", false)
	else:
		decal_material.set_shader_parameter("use_normal_map", true)

	if flipbook_play:
		_clock += delta

		if _clock >= (1.0 / flipbook_fps):
			_clock = 0.0
			flipbook_current_frame = (flipbook_current_frame + 1)

			if (
				flipbook_playback_type == PlaybackType.ONE_SHOT
				&& (flipbook_current_frame >= (flipbook_columns_count * flipbook_columns_count) - 1)
			):
				flipbook_play = false
