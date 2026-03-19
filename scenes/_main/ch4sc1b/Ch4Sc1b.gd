extends Scene

const TriggerArea = preload("res://components/TriggerArea.gd")
const InteractiveArea = preload("res://components/InteractiveArea/InteractiveArea.gd")

@export var total_interactables: int
@export var ta_louise_thought_path: NodePath
@export var ia_water_jug_path: NodePath
@export var ia_mark_sit_path: NodePath

@onready var ta_louise_thought = get_node(ta_louise_thought_path) as TriggerArea
@onready var ia_water_jug = get_node(ia_water_jug_path) as InteractiveArea
@onready var ia_mark_sit = get_node(ia_mark_sit_path) as InteractiveArea

@onready var minigame_board = $Main/BoardLayer/MinigameLabBoard

var _items_iteracted: int

var scene_id: String
var flipped: bool


func _ready():
	super._ready()
	scene_id = scene_manager.scene_id

	ta_louise_thought.visible = false
	ia_water_jug.visible = false
	ia_mark_sit.visible = false

	Story.emitted.connect(_on_story_emit)
	minigame_board.pin_removed.connect(_on_pin_removed)
	minigame_board.all_pins_removed.connect(_on_lab_board_all_pins_removed)

func _on_story_emit(emit: String, value):
	match emit:
		"minigame_board":
			minigame_board.appear()
		"item_interacted":
			_items_iteracted += 1
			_check_items_interacted()
		"lab_board_trophy":
			_start_short("vo_impressive")
		"lab_board_sign_ups":
			_start_short("vo_she_knows")
		"allow_mark_sit":
			ia_mark_sit.visible = true


func _check_items_interacted():
	var half_interactables = total_interactables / 2

	match _items_iteracted:
		# Prevents water jug from being interactive right at the start
		half_interactables:
			ia_water_jug.visible = true
		total_interactables:
			ta_louise_thought.visible = true


func _start_short(knot: String):
	var id = "%s.%s" % [scene_id, knot]
	await Story.start_short(id)


func _on_pin_removed():
	if minigame_board.pins_removed == 1:
		_start_short("vo_take_pins")

func _on_lab_board_all_pins_removed():
	Game.dist_platform.unlock_achievement("ACH_MATIGAS_ULO")
	Game.savegame.save_board_cleared(key)
