extends Node

@onready var focus = $Focus
@onready var minigame_usb = get_parent()
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	scene_manager.shot_changed.connect(_on_shot_changed)
	minigame_usb.minigame_finished.connect(_on_minigame_finished)


func _on_shot_changed(shot: String):
	var active = shot == "MinigameUSB"
	minigame_usb.visible = active

	if active:
		focus.push()
		minigame_usb.present_control_hint()
	else:
		focus.pop()


func _on_minigame_finished():
	focus.pop()
	Story.emit("minigame_usb_finished")
