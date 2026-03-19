extends Control

const Savegame = preload("res://data/Savegame.gd")
const InitialSettingsScreen = preload("res://ui/screens/Game/InitialSettingsScreen/InitialSettingsScreen.tscn")

@onready var animation_player = $AnimationPlayer
@onready var prompt = $Prompt

func _ready():
	prompt.answered.connect(_on_prompt_answered)
	animation_player.play("enter")

func _on_prompt_answered(state):
	if state:
		Game.savegame = Savegame.new()
		Game.save_savegame()
		Game.change_scene_to(InitialSettingsScreen)
	else:
		# just exit
		get_tree().quit()
