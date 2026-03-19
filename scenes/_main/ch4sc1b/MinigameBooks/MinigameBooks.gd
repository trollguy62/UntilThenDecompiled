extends Node2D

const SceneManager = preload("res://components/SceneManager.gd")
const ClickableObject = preload("ClickableObject.gd")

@export var exit_shot := "CamFollow"

@onready var focus = $Focus
@onready var input_blocker = $InputBlocker

@onready var default = $Default
@onready var sky_atlas_open = $SkyAtlasOpen
@onready var clickable_sky_atlas = $SkyAtlas
@onready var scene_manager = Service.of("SceneManager")
@onready var scene_id = scene_manager.scene_id

@onready var sfx_notebook = $OpeningNotebook

var clickable_objects := []
var triggered_shorts := []
var short_in_progress  = false

func _ready():
	Utils.search_descendants(self, _is_clickable_obj, clickable_objects)

	for clickable in clickable_objects:
		var obj = clickable as ClickableObject
		obj.requested_start_short.connect(_on_requested_start_short)


func _is_clickable_obj(node: Node) -> bool:
	return node is ClickableObject


func _on_requested_start_short(knot: String):
	if short_in_progress:
		return
	if knot in triggered_shorts:
		return
	
	triggered_shorts.append(knot)
	short_in_progress = true
	
	for clickable in clickable_objects:
		var obj = clickable as ClickableObject
		if obj.short_knot == knot:
			obj.enabled = false

	if knot == clickable_sky_atlas.short_knot:
		_set_sky_atlas_open(true)

	var id = "%s.%s" % [scene_id, knot]
	await Story.start_short(id)
	short_in_progress = false

func _process(delta):
	input_blocker.visible = not focus.active

	if visible != focus.active:
		if visible:
			focus.push()
		else:
			focus.pop()


func _set_sky_atlas_open(open: bool):
	sfx_notebook.play()
	default.visible = not open
	sky_atlas_open.visible = open

func _input(event):
	if not focus.active:
		return

	#keyboard
	if event is InputEventKey and event.is_action_pressed("interact"):
		scene_manager.change_shot(exit_shot)

	#controller
	if event.is_action_pressed("c_cancel"):
		scene_manager.change_shot(exit_shot)
