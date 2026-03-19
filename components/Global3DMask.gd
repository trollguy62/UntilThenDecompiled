extends Node

# Hides VisualInstances using their layers. Hidden instances, regardless of
# their original layers, are put under the reserved mask layer, which the camera culls.

# This is under the assumption that VisualInstance layers do NOT change value
# while they are hidden using this. Otherwise, their layers are restored
# to the value that was saved the moment it got hidden, which might not be up to date.

# Setting `visible` wasn't a good approach since it is more commonly set than layers.
# P.S. This is a quite rough solution for debug overriding visibility. Refactor if possible.

const LAYER_CHAR_NPC = 1 << 5
const LAYER_CHAR_STORY = 1 << 6
const LAYER_CHAR_PLAYER = 1 << 7
const LAYER_RESERVED_MASK = 1 << 19

@export_flags_3d_render var hide_mask: int = 0:
	set(value):
		if hide_mask == value:
			return

		hide_mask = value
		_restore_visual_instances()

var is_valid = _must_hide
var layers_cache := {}  # Dictionary<VisualInstance, int>
var cast_shadow_cache := {}  # Dictionary<GeometryInstance, int>


func _ready():
	process_priority = 10
	process_mode = PROCESS_MODE_ALWAYS

	Game.config.hide_props_changed.connect(_update_from_game_config)
	_update_from_game_config()


func _update_from_game_config():
	var config = Game.config
	self.hide_mask = (
		LAYER_CHAR_NPC * (1 if config.hide_npcs else 0)
		+ LAYER_CHAR_STORY * (1 if config.hide_story_chars else 0)
		+ LAYER_CHAR_PLAYER * (1 if config.hide_player else 0)
	)


func _process(delta):
	_update_camera_cull_mask()

	if hide_mask == 0:
		return

	var root = Utils.get_root_scene()
	if root == null:
		return

	var instances := []
	Utils.search_descendants(root, is_valid, instances)

	for inst in instances:
		if not inst in layers_cache:
			layers_cache[inst] = inst.layers

		if not inst in cast_shadow_cache and inst is GeometryInstance3D:
			cast_shadow_cache[inst] = inst.cast_shadow

		inst.layers = LAYER_RESERVED_MASK

		if inst is GeometryInstance3D:
			inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _update_camera_cull_mask():
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return

	var cull_mask = camera.cull_mask

	if hide_mask > 0:
		cull_mask &= ~LAYER_RESERVED_MASK
	else:
		cull_mask |= LAYER_RESERVED_MASK

	camera.cull_mask = cull_mask


func _restore_visual_instances():
	for inst in layers_cache:
		if not is_instance_valid(inst):
			continue

		inst.layers = layers_cache[inst]

		if inst is GeometryInstance3D:
			inst.cast_shadow = cast_shadow_cache[inst]

	layers_cache.clear()
	cast_shadow_cache.clear()


func _must_hide(node: Node) -> bool:
	if node is VisualInstance3D:
		return (node.layers & hide_mask) > 0
	return false
