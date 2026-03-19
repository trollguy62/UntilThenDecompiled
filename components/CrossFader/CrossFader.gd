extends ColorRect

const SceneCamera = preload("res://components/SceneCamera.gd")

@export var take_current_frame_if_possible := false
@export var bypass_skit_check := false

@onready var tween = Threen.new()

var _command_handler = _run_command
var _skit_container: SkitContainer


func _ready():
	visible = false
	add_child(tween)


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)
	get_viewport().disable_3d = false


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container


func _is_skit_running() -> bool:
	return bypass_skit_check or \
			(is_instance_valid(_skit_container) and _skit_container.is_running)


func _find_scene_camera(shot: String) -> SceneCamera:
	if not _is_skit_running():
		return null
	return Utils.search_node(_is_scene_camera_of_shot.bind(shot), _skit_container)


func _is_scene_camera_of_shot(node: Node, shot: String) -> bool:
	return node is SceneCamera and node.shot == shot


func _capture_camera(camera: Camera3D) -> Texture:
	assert(camera.is_inside_tree())

	if camera.current and take_current_frame_if_possible:
		return ImageTexture.create_from_image(get_tree().root.get_texture().get_image())

	var parent = camera.get_parent()
	var camera_dupe: Camera3D = camera.duplicate()

	var viewport = SubViewport.new()
	var root_vp = get_tree().root

	viewport.size = root_vp.size
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.positional_shadow_atlas_size = root_vp.positional_shadow_atlas_size
	viewport.positional_shadow_atlas_quad_0 = root_vp.positional_shadow_atlas_quad_0
	viewport.positional_shadow_atlas_quad_1 = root_vp.positional_shadow_atlas_quad_1
	viewport.positional_shadow_atlas_quad_2 = root_vp.positional_shadow_atlas_quad_2
	viewport.positional_shadow_atlas_quad_3 = root_vp.positional_shadow_atlas_quad_3

	parent.add_child(viewport)
	viewport.add_child(camera_dupe)
	camera_dupe.make_current()
	camera_dupe.global_transform = camera.global_transform

	await RenderingServer.frame_post_draw

	var tex = ImageTexture.create_from_image(viewport.get_texture().get_image())

	viewport.queue_free()
	return tex


func cross_fade_to(texture: Texture, duration: float = 0.0):
	material.set_shader_parameter("tex_1", material.get_shader_parameter("tex_2"))
	material.set_shader_parameter("tex_2", texture)
	material.set_shader_parameter("t", 0.0)

	tween.interpolate_property(material, "shader_parameter/t", 0.0, 1.0, duration)
	tween.start()
	await tween.tween_completed


func cross_fade_to_camera(camera: Camera3D, duration: float = 0.0):
	var texture = await _capture_camera(camera)
	await cross_fade_to(texture, duration)


func _run_command(cmd: Command):
	if not _is_skit_running():
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"cross_fade_to_camera":
			var shot = str(cmd.params[0])
			var duration = float(Utils.array_get(cmd.params, 1, 0))

			var scene_camera = _find_scene_camera(shot)
			if scene_camera == null:
				return Constants.CMD_RETURN_NONE

			await cross_fade_to_camera(scene_camera, duration)
		"show_cross_fader":
			visible = true
			get_viewport().disable_3d = true
		"hide_cross_fader":
			visible = false
			get_viewport().disable_3d = false
		_:
			return Constants.CMD_RETURN_NONE
