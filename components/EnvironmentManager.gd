extends Node3D

const META_KEY_RESTORE_PROPS = "restore_props"

@onready var _viewport: Viewport = get_viewport()
@onready var _world: World3D = get_world_3d()

var disable_reflections := false
var disable_ssao := false
var disable_gi := false
var disable_glow := false
var disable_bokeh := false
var disable_volumetric_fog := false

var _original_environment: Environment = null
var _original_camera_attributes: CameraAttributes = null

var _reflection_probes: Array[ReflectionProbe] = []
var _voxel_gis: Array[VoxelGI] = []


func _ready():
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	RenderingServer.frame_pre_draw.connect(_on_frame_pre_draw)
	RenderingServer.frame_post_draw.connect(_on_frame_post_draw)


func _on_node_added(node: Node):
	if node is ReflectionProbe and not node in _reflection_probes:
		_reflection_probes.append(node)
	elif node is VoxelGI and not node in _voxel_gis:
		_voxel_gis.append(node)


func _on_node_removed(node: Node):
	if node is ReflectionProbe:
		_reflection_probes.erase(node)
	elif node is VoxelGI:
		_voxel_gis.erase(node)


func _on_frame_pre_draw():
	var env: Environment = _get_current_environment()
	_original_environment = env
	_original_camera_attributes = null

	if env == null:
		return

	if disable_reflections:
		_set_obj_prop(env, "ssr_enabled", false)

		for probe in _reflection_probes:
			_set_obj_prop(probe, "layers", 0)

	if disable_ssao:
		_set_obj_prop(env, "ssao_enabled", false)
		_set_obj_prop(env, "ssil_enabled", false)

	if disable_gi:
		_set_obj_prop(env, "sdfgi_enabled", false)

		for gi in _voxel_gis:
			# TODO: Known Godot issue that a GI that starts out hidden can no longer show up
			# Thus, switching from off (must be the case when scene started) to on doesn't work
			_set_obj_prop(gi, "layers", 0)

	if disable_glow:
		_set_obj_prop(env, "glow_enabled", false)

	if disable_bokeh:
		var attrs: CameraAttributes = _get_current_camera_attributes()
		if attrs != null and attrs is CameraAttributesPractical:
			_original_camera_attributes = attrs
			_set_obj_prop(attrs, "dof_blur_amount", 0)

	if disable_volumetric_fog:
		_set_obj_prop(env, "volumetric_fog_enabled", false)


func _on_frame_post_draw():
	if is_instance_valid(_original_environment):
		_restore_env_props(_original_environment)

	if is_instance_valid(_original_camera_attributes):
		_restore_env_props(_original_camera_attributes)

	for probe in _reflection_probes:
		_restore_env_props(probe)

	for gi in _voxel_gis:
		_restore_env_props(gi)


func _set_obj_prop(obj, prop: String, value):
	if not obj.has_meta(META_KEY_RESTORE_PROPS):
		obj.set_meta(META_KEY_RESTORE_PROPS, {})

	var restore_props: Dictionary = obj.get_meta(META_KEY_RESTORE_PROPS)
	assert(restore_props != null)

	restore_props[prop] = obj[prop]
	obj[prop] = value


func _restore_env_props(obj):
	var restore_props: Dictionary = obj.get_meta(META_KEY_RESTORE_PROPS, {})

	for prop in restore_props:
		obj[prop] = restore_props[prop]

	obj.remove_meta(META_KEY_RESTORE_PROPS)


func _get_current_environment() -> Environment:
	var camera: Camera3D = _viewport.get_camera_3d()
	if camera != null and camera.environment:
		return camera.environment

	if _world.environment:
		return _world.environment

	return _world.fallback_environment


func _get_current_camera_attributes() -> CameraAttributes:
	var camera: Camera3D = _viewport.get_camera_3d()
	if camera != null and camera.attributes:
		return camera.attributes

	return _world.camera_attributes
