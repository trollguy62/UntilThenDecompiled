@tool
extends Node

@export var state_container_alias: String
@export var enabled := true:
	set = _set_enabled,
	get = _get_enabled
@export var fallback_standalone_anim := ""
@export var fallback_idle_talk_anim := ""
@export var standalone_anims: Array[String]
@export var idle_talk_anims: Array[String]

@export var debug_auto_list_anims := false:
	set = _set_debug_auto_list_anims,
	get = _get_debug_auto_list_anims

var scene_manager: SceneManager
var state: StateContainer
var sprite: Node


func _ready():
	if Engine.is_editor_hint():
		return

	scene_manager = Service.of("SceneManager") as SceneManager
	state = Utils.get_state_container_of(state_container_alias) as StateContainer
	sprite = _get_sprite_node()

	assert(state is StateContainer)
	assert(sprite is AnimatedSprite2D or sprite is AnimatedSprite3D or sprite is AnimatedPaper3D)

	state.changed.connect(_on_state_changed)
	scene_manager.shot_changed.connect(_on_scene_shot_changed)


func _get_sprite_node():
	var node = get_node_or_null("../Sprite")
	if node == null:
		node = get_parent()
	return node


func _set_enabled(value: bool):
	enabled = value
	if enabled and scene_manager != null:
		_update_animation()


func _get_enabled():
	return enabled


func _on_state_changed():
	_update_animation()


func _on_scene_shot_changed(_shot: String):
	_update_animation()


func _update_animation():
	if enabled:
		sprite.animation = get_animation()


func _has_animation(anim: String) -> bool:
	var frames: SpriteFrames

	if sprite is AnimatedPaper3D:
		frames = sprite.texture_frames
	else:
		frames = sprite.sprite_frames

	return frames.has_animation(anim)


func get_animation() -> String:
	var flags: Set = state.flags
	var dict: ObservableDict = state.dict
	var talking = flags.has("$talk")
	var walking = flags.has("$walk")
	var candidates = []

	var with = dict.get_value("with", "")
	var look_at = dict.get_value("look_at", "")

	for anim in standalone_anims:
		if flags.has(anim):
			_add_candidates(candidates, anim, with, look_at)
			break

	for anim in idle_talk_anims:
		if flags.has(anim):
			_add_candidates(candidates, anim, with, look_at)

	if fallback_standalone_anim != "":
		_add_candidates(candidates, fallback_standalone_anim, with, look_at)

	if fallback_idle_talk_anim != "":
		_add_candidates(candidates, fallback_idle_talk_anim, with, look_at)

	for anim in candidates:
		var subcandidates = ["%s_idle" % anim, anim]
		if talking:
			subcandidates.push_front("%s_talk" % anim)
		if walking:
			subcandidates.push_front("%s_walk" % anim)

		for sub_anim in subcandidates:
			if _has_animation(sub_anim):
				return sub_anim

	return sprite.animation


func _add_candidates(candidates: Array, animation: String, with: String, look_at: String):
	if with != "" and look_at != "":
		candidates.append("%s+%s=%s" % [animation, with, look_at])

	if look_at != "":
		candidates.append("%s=%s" % [animation, look_at])

	if with != "":
		candidates.append("%s+%s" % [animation, with])

	candidates.append(animation)


func _set_debug_auto_list_anims(value):
	var old_value = debug_auto_list_anims
	debug_auto_list_anims = value

	if not old_value and value:
		_auto_list_anims()


func _get_debug_auto_list_anims() -> bool:
	return debug_auto_list_anims


func _auto_list_anims():
	var sprite: AnimatedPaper3D = _get_sprite_node()
	if sprite == null:
		print("%s: Sprite not found" % get_path())
		return

	standalone_anims.clear()
	idle_talk_anims.clear()

	if sprite.texture_frames == null:
		print("%s: Sprite sibling has no texture frames")
		return

	for anim in sprite.texture_frames.get_animation_names():
		var is_idle = anim.ends_with("_idle")
		var is_talk = anim.ends_with("_talk")
		var is_idle_talk = is_idle or is_talk

		if is_idle:
			anim = anim.trim_suffix("_idle")
		elif is_talk:
			anim = anim.trim_suffix("_talk")

		var end = _min_nonneg([anim.find("+"), anim.find("=")])
		if end >= 0:
			anim = anim.substr(0, end)

		_append_if_unique(idle_talk_anims if is_idle_talk else standalone_anims, anim)

	print(idle_talk_anims)


func _min_nonneg(array: Array):
	var ret = -1

	for x in array:
		if x >= 0:
			ret = x if ret < 0 else min(ret, x)

	return ret


func _append_if_unique(array: Array, item):
	if not item in array:
		array.append(item)
