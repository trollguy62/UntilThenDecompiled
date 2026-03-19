@tool
extends MeshInstance3D
class_name AnimatedPaper3D

signal frame_changed
signal animation_finished

const PaperMesh = preload("paper_3d_plane.obj")
const PaperMaterial = preload("AnimatedPaper3D.tres")
const PaperMaterialNoDepthTest = preload("AnimatedPaper3DNoDepthTest.tres")
const PaperMaterialShader = preload("AnimatedPaper3D.gdshader")
const PaperMaterialTransparentShader = preload("AnimatedPaper3DTransparent.gdshader")
const PaperMaterialUnshadedShader = preload("AnimatedPaper3DUnshaded.gdshader")

const TEXTURE_ALBEDO = 0
const TEXTURE_NORMAL = 1
const TEXTURE_EMISSION = 2

@export var texture_frames: SpriteFrames
@export var normal_frames: SpriteFrames
@export var emission_frames: SpriteFrames
@export var local_offsets := {}  # Map<String, Vector3>
@export var local_flip_h: Array[String] = []
@export var local_flip_v: Array[String] = []
@export var sync_groups: Array[Array] = [] #Array[Array[String]]
@export var sync_all := false
@export var sync_all_except: Array[String] = []
@export var reflect_h_width := 0

@export var animation: String:
	set(value):
		_set_animation(value)
	get:
		return _animation

@export_range(0, 99) var frame: int = 0:
	set(value):
		var new_frame = value
		var anim_looping = false
		var anim_finished = false

		if has_animation(_animation):
			anim_looping = texture_frames.get_animation_loop(_animation)
			var frame_count = texture_frames.get_frame_count(_animation)

			if value == frame_count:
				anim_finished = true

			if anim_looping:
				new_frame = value % frame_count
			else:
				new_frame = clamp(value, 0, max(0, frame_count - 1))

		if frame != new_frame:
			frame = new_frame
			frame_changed.emit()
			_call_frame_invokers()

		if anim_finished:
			if stop_on_finish and not anim_looping:
				stop()

			animation_finished.emit()

@export var playing := true:
	set(value):
		if playing != value:
			playing = value
			_editor_save_frame = frame
	get:
		return playing

@export var reverse := false
@export var random_initial := false
@export_range(0.01, 64) var speed_multiplier: float= 1.0
@export var alias := ""

@export var transitions: Array[AnimationTransition] = []
@export var frame_invokers: Array[AnimationFrameInvoker] = []

@export_range(0.0001, 16) var pixel_size: float = 0.01
@export var centered := false
@export var flip_h := false
@export var flip_v := false
@export var offset := Vector3()
@export var modulate := Color.WHITE
@export_range(0, 16) var normal_depth: float = 1.0
@export var emission_mult: Color = Color.WHITE
@export_range(0, 16) var emission_strength: float = 0.0

@export var transparent := false:
	set(value):
		transparent = value

		if mesh == null or _material == null:
			return

		_update_material_shader()

@export var unshaded := false:
	set(value):
		unshaded = value

		if mesh == null or _material == null:
			return

		_update_material_shader()

@export var depth_test_disabled := false:
	set(value):
		depth_test_disabled = value

		if mesh == null or _material == null:
			return

		if depth_test_disabled:
			if _next_pass_material == null || _next_pass_material.shader != PaperMaterialNoDepthTest.shader:
				_next_pass_material = PaperMaterialNoDepthTest.duplicate()

			_material.next_pass = _next_pass_material
		else:
			_material.next_pass = null

@export_range(0, 1) var glitch_fac: float = 0.0:
	set(value):
		glitch_fac = value

		if mesh == null or _material == null:
			return

		_update_material_shader()

@export var stop_on_finish := false
@export var unique_mesh := false

@export var debug_show_frame := false
@export_multiline var debug_add_anim_str := ""
@export var debug_add_anim_fps := 6.0
@export var debug_add_anim_go := false:
	set(value):
		var old_value = debug_add_anim_go
		debug_add_anim_go = value

		if old_value or not value or texture_frames == null:
			return

		for ln in debug_add_anim_str.split("\n"):
			var source = ln.strip_edges()
			var mediator = ""
			var permutations := []
			var i = 0

			while true:
				var a = source.find("(", i)
				if a < 0:
					break

				var b = source.find(")", a)
				var choices = source.substr(a + 1, b - a - 1).split("/")
				permutations.append(choices)

				mediator += "%s[%d]" % [source.substr(i, a - i), permutations.size() - 1]
				i = b + 1

			var anims := []

			if permutations.size() > 0:
				anims = _get_debug_add_anims(mediator, permutations, 0)
			else:
				anims = [source]

			for anim in anims:
				texture_frames.add_animation(anim)
				texture_frames.set_animation_speed(anim, debug_add_anim_fps)


@export var debug_to_prev_anim := false:
	set(value):
		if value:
			_debug_cycle_anim(false)

@export var debug_to_next_anim := false:
	set(value):
		if value:
			_debug_cycle_anim(true)

var current_texture_frame: Texture:
	get:
		return texture_frames.get_frame_texture(_animation, frame)

var _animation := "default"

var _t := 0.0
var _material: ShaderMaterial
var _next_pass_material: ShaderMaterial

var _current_transition: AnimationTransition
var _next_animation := ""

var _editor_save_frame := frame
var _editor_last_frame := frame


func _ready():
	animation_finished.connect(_on_animation_finished)

	if mesh == null or unique_mesh:
		mesh = PaperMesh.duplicate()

	_material = mesh.surface_get_material(0)

	if _material == null:
		_material = PaperMaterial.duplicate()
		mesh.surface_set_material(0, _material)

	_next_pass_material = _material.next_pass
	self.depth_test_disabled = depth_test_disabled
	self.glitch_fac = glitch_fac

	if alias == "":
		alias = name

	if random_initial and has_animation(_animation):
		var frames = texture_frames.get_frame_count(_animation)
		self.frame = randi() % frames
		_t = randf() * 0.2


func _process(delta):
	if playing and has_animation(_animation):
		_t += delta

		var T = 1.0 / texture_frames.get_animation_speed(_animation)
		T /= clamp(speed_multiplier, 0.01, 64)

		if _t >= T:
			var incr = int(floor(_t / T))
			self.frame += incr
			_t -= incr * T

	_update()


func _update():
	if not has_animation(_animation):
		return

	var real_frame = frame
	if reverse:
		real_frame = texture_frames.get_frame_count(_animation) - frame - 1

	var texture = texture_frames.get_frame_texture(_animation, real_frame)
	var tex_size = texture.get_size()
	var normal = null
	var emission = null

	if normal_frames:
		normal = _get_frame_or_null(normal_frames, _animation, real_frame)

	if emission_frames:
		emission = _get_frame_or_null(emission_frames, _animation, real_frame)

	var scale_2d = tex_size * pixel_size
	var scale_3d = Vector3(scale_2d.x, scale_2d.y, 1)

	var flip_h = self.flip_h or _animation in local_flip_h
	var flip_v = self.flip_v or _animation in local_flip_v

	var offset_px_3d = (
		offset
		+ (Vector3(tex_size.x / 2.0, tex_size.y / 2.0, 0) if centered else Vector3())
	)
	var local_offset = local_offsets.get(_animation, Vector3())

	if reflect_h_width > 0 and flip_h:
		local_offset.x = reflect_h_width - tex_size.x - local_offset.x

	offset_px_3d += local_offset
	var offset_3d = offset_px_3d * pixel_size

	var aabb = mesh.get_aabb()
	aabb.position = offset_3d
	aabb.size = offset_3d + Vector3(scale_2d.x, scale_2d.y, 0)
	set_custom_aabb(aabb)  # TODO confirm correctness

	_update_paper_material(
		_material,
		scale_3d,
		offset_3d,
		flip_h,
		flip_v,
		texture,
		normal,
		emission,
		modulate,
		normal_depth
	)

	if _next_pass_material != null:
		_update_paper_material(
			_next_pass_material,
			scale_3d,
			offset_3d,
			flip_h,
			flip_v,
			texture,
			normal,
			emission,
			modulate,
			normal_depth
		)

# Prevent unwanted changes by making the frame and shader params consistent on save
func _notification(what: int):
	if not Engine.is_editor_hint():
		return

	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_editor_last_frame = frame

		if not playing:
			_editor_save_frame = frame

		frame = _editor_save_frame
		_update()
		_reset_aabb()

	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		frame = _editor_last_frame


func _update_paper_material(
	mat: ShaderMaterial,
	scale_3d: Vector3,
	offset_3d: Vector3,
	flip_h: bool,
	flip_v: bool,
	texture_albedo: Texture,
	texture_normal: Texture,
	texture_emission: Texture,
	albedo: Color,
	normal_depth: float
):
	mat.set_shader_parameter("scale", scale_3d)
	mat.set_shader_parameter("offset", offset_3d)
	mat.set_shader_parameter("flip_h", flip_h)
	mat.set_shader_parameter("flip_v", flip_v)
	mat.set_shader_parameter("texture_albedo", texture_albedo)
	mat.set_shader_parameter("texture_normal", texture_normal)
	mat.set_shader_parameter("texture_emission", texture_emission)
	mat.set_shader_parameter("region_albedo", _get_texture_region(texture_albedo))
	mat.set_shader_parameter("region_normal", _get_texture_region(texture_normal))
	mat.set_shader_parameter("region_emission", _get_texture_region(texture_emission))
	mat.set_shader_parameter("margin_albedo", _get_texture_margin(texture_albedo))
	mat.set_shader_parameter("margin_normal", _get_texture_margin(texture_normal))
	mat.set_shader_parameter("margin_emission", _get_texture_margin(texture_emission))
	mat.set_shader_parameter("albedo", albedo)
	mat.set_shader_parameter("normal_depth", normal_depth)
	mat.set_shader_parameter("emission_mult", emission_mult)
	mat.set_shader_parameter("emission_strength", emission_strength)
	mat.set_shader_parameter("debug_show_frame", debug_show_frame and Engine.is_editor_hint())
	mat.set_shader_parameter("glitch_fac", glitch_fac)


func _get_texture_region(texture: Texture) -> Rect2:
	if texture == null:
		return Rect2()
	elif texture is AtlasTexture:
		return texture.region
	else:
		return Rect2(Vector2.ZERO, texture.get_size())


func _get_texture_margin(texture: Texture) -> Rect2:
	if texture is AtlasTexture:
		return texture.margin
	else:
		return Rect2()


func _get_frame_or_null(sprite_frames: SpriteFrames, animation: String, frame: int) -> Texture:
	if sprite_frames.has_animation(animation) and frame < sprite_frames.get_frame_count(animation):
		return sprite_frames.get_frame_texture(animation, frame)
	return null


func _set_animation(new_animation, force: bool = false):
	if not force and _animation == new_animation:
		return

	if _current_transition:
		_next_animation = new_animation
		return

	var transition: AnimationTransition = _get_applicable_transition(_animation, new_animation)
	var sync_anims := false

	if transition:
		_current_transition = transition
		new_animation = transition.anim
		reverse = transition.is_reversed(_animation)
	else:
		sync_anims = _is_syncable(_animation, new_animation)

	_animation = new_animation
	_t = 0

	if sync_anims:
		var frame_count = texture_frames.get_frame_count(new_animation)
		if frame_count > 0:
			frame %= frame_count
			return

	frame = 0


func _call_frame_invokers():
	if Engine.is_editor_hint():
		return

	for invoker in frame_invokers:
		var i := invoker as AnimationFrameInvoker
		if _animation.matchn(i.animation) and frame == i.frame:
			i.invoke(self)


func has_animation(anim: String) -> bool:
	return texture_frames and texture_frames.has_animation(anim)


func _get_applicable_transition(from_anim: String, to_anim: String) -> AnimationTransition:
	for i in range(transitions.size()):
		var trans: AnimationTransition = transitions[i]

		if trans == null:
			continue

		if trans.matches(from_anim, to_anim):
			return trans

	return null


func _is_syncable(from_anim: String, to_anim: String) -> bool:
	if (
		sync_all
		and _current_transition == null
		and not sync_all_except.has(from_anim)
		and not sync_all_except.has(to_anim)
	):
		return true

	for sync_group in sync_groups:
		if from_anim in sync_group and to_anim in sync_group:
			return true

	return false


func _on_animation_finished():
	if _current_transition == null:
		return

	_animation = _current_transition.from_anim if reverse else _current_transition.to_anim
	frame = 0
	_current_transition = null
	reverse = false

	if _next_animation != "":
		var tmp = _next_animation
		_next_animation = ""
		_set_animation(tmp)


func play(anim: String = "", force: bool = false):
	if has_animation(anim):
		_set_animation(anim, force)
	playing = true


func stop():
	playing = false


func _update_material_shader():
	if unshaded:
		_material.shader = PaperMaterialUnshadedShader
	elif transparent:
		_material.shader = PaperMaterialTransparentShader
	else:
		_material.shader = PaperMaterialShader


func _set_debug_add_anim_go(value):
	var old_value = debug_add_anim_go
	debug_add_anim_go = value

	if old_value or not value or texture_frames == null:
		return

	var source = debug_add_anim_str
	var mediator = ""
	var permutations := []
	var i = 0

	while true:
		var a = source.find("(", i)
		if a < 0:
			break

		var b = source.find(")", a)
		var choices = source.substr(a + 1, b - a - 1).split("/")
		permutations.append(choices)

		mediator += "%s[%d]" % [source.substr(i, a - i), permutations.size() - 1]
		i = b + 1

	var anims := []

	if permutations.size() > 0:
		anims = _get_debug_add_anims(mediator, permutations, 0)
	else:
		anims = [source]

	for anim in anims:
		texture_frames.add_animation(anim)
		texture_frames.set_animation_speed(anim, debug_add_anim_fps)


func _get_debug_add_anims(mediator: String, permutations: Array, n: int) -> Array:
	var strings := []

	for i in range(permutations[n].size()):
		var perm = permutations[n][i]
		var submediator = mediator.replace("[%d]" % n, perm)

		if n + 1 < permutations.size():
			var ret = _get_debug_add_anims(submediator, permutations, n + 1)
			strings.append_array(ret)
		else:
			strings.append(submediator)

	return strings

func _debug_cycle_anim(next: bool):
	var anim_names = Array(texture_frames.get_animation_names())
	var anim_count = anim_names.size()
	var idx = anim_names.find(_animation)

	if idx >= 0:
		idx += 1 if next else -1
		idx = int(fposmod(idx, anim_count))

		_set_animation(anim_names[idx])
		print("(%d) %s" % [idx, _animation])


### Command handler ###
var _command_handler = _run_command

func _reset_aabb():
	set_custom_aabb(AABB())


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if not is_visible_in_tree() or params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_anim":
			var anim = params[1]
			var force = flags.has("force")

			if has_animation(anim):
				play(anim, force)
		"play_anim":
			var anim = params[1]
			var force = flags.has("force")

			if has_animation(anim):
				play(anim, force)
				await animation_finished
		"flip_h":
			var value = not flip_h
			if params.size() >= 2:
				value = bool(params[1])
			flip_h = value
		"flip_v":
			var value = not flip_v
			if params.size() >= 2:
				value = bool(params[1])
			flip_v = value
		"is_flip_h":
			return flip_h
		"is_flip_v":
			return flip_v
		_:
			return Constants.CMD_RETURN_NONE

	return null
