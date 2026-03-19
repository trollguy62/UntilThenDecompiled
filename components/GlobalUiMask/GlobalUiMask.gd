extends CanvasLayer

const LAYER_INGAME_UI = 1 << 5
const LAYER_BUBBLES = 1 << 6

const LAYER_CHAR_NPC = 1 << 7
const LAYER_CHAR_STORY = 1 << 8
const LAYER_CHAR_PLAYER = 1 << 9

@export_flags_2d_render var cull_mask: int = 0:
	set(value):
		if cull_mask == value:
			return

		cull_mask = value
		light_mask.range_item_cull_mask = cull_mask


@onready var light_mask = $LightMask


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	Game.config.hide_props_changed.connect(_update_from_game_config)
	_update_from_game_config()


func _update_from_game_config():
	var config = Game.config
	self.cull_mask = (
		LAYER_INGAME_UI * (1 if config.hide_ingame_ui else 0)
		+ LAYER_BUBBLES * (1 if config.hide_bubbles else 0)
		+ LAYER_CHAR_NPC * (1 if config.hide_npcs else 0)
		+ LAYER_CHAR_STORY * (1 if config.hide_story_chars else 0)
		+ LAYER_CHAR_PLAYER * (1 if config.hide_player else 0)
	)
