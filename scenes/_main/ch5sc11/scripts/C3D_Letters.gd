extends Node3D

const SceneManager = preload("res://components/SceneManager.gd")

@export var exit_shot := "CamMain"

@onready var scene_manager = Service.of("SceneManager") as SceneManager
@onready var focus = $Focus
@onready var pointer = $Pointer

var short_trigger = false


func _process(delta):
	pointer.visible = visible
	if visible != focus.active:
		if visible:
			focus.push()
		else:
			focus.pop()


func _unhandled_input(event):
	if (event.is_action_pressed("k_interact") or event.is_action_pressed("c_cancel")) and focus.active:
		scene_manager.change_shot(exit_shot)
		if not short_trigger:
			scene_manager.start_short("after_reading_letter")
			short_trigger = true
