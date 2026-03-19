extends Node2D

const SceneManager = preload("res://components/SceneManager.gd")
const Sprite2DMouseMovable = preload("res://components/Sprite2DMouseMovable.gd")

@export var exit_shot := "CamWalk"

@onready var scene_manager = Service.of("SceneManager") as SceneManager

@onready var focus = $Focus
@onready var input_blocker = $InputBlocker
@onready var sheet_music = $SheetMusic.get_children()

func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _ready():
	for sm in sheet_music:
		assert(sm is Sprite2DMouseMovable)
		sm.clicked.connect(_on_sheet_music_clicked.bind(sm.name))


func _process(delta):
	input_blocker.visible = not focus.active

	if visible != focus.active:
		if visible:
			focus.push()
		else:
			focus.pop()

func _on_sheet_music_clicked(music_name: String):
	if focus.active:
		enable_sheet_music(false)
		var knot = "Practice_sheet_music_" + music_name
		await scene_manager.start_short(knot)
		enable_sheet_music(true)

func enable_sheet_music(enable):
	for sm in sheet_music:
		sm.enabled = enable

func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"enable_sheet_music":
			enable_sheet_music(bool(params[0]))
		_:
			return Constants.CMD_RETURN_NONE

	return null

func _unhandled_input(event):
	if (event.is_action_pressed("c_cancel") or event.is_action_pressed("k_interact")) and focus.active:
		scene_manager.change_shot(exit_shot)
