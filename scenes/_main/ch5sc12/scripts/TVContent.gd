extends Node

#FIXME: hack. look for this in the node tree
@export var credits: Control
#
@onready var fallback = $Fallback

@onready var continue_prompt = $ContinuePrompt
@onready var results = $Results
@onready var racing_minigame_path = preload("res://scenes/_main/ch5sc12/racing-minigame/RaceMinigame.tscn")
@onready var replay_menu = $ReplayMenu

var racing_minigame


func _ready():
	Story.emitted.connect(_on_story_emitted)
	credits.credits_finished.connect(_on_credits_finished)
	replay_menu.ui_animation_finished.connect(_on_event_emitted)
	hide_all()
	fallback.visible = true


func _on_game_finished(result):
	hide_all()
	results.display_result(result)
	Story.emit("game_finished")


func _on_event_emitted(ev):
	Story.emit(ev)


func _on_story_emitted(name: String, value):
	match name:
		"roll_credits":
			hide_all()
			fallback.visible = true
			credits.visible = true
			credits.roll()
		"continue_promopt":
			hide_all()
			continue_prompt.visible = true
		"start_game":
			hide_all()
			init_minigame()
			racing_minigame.start_game()
		"show_replay_menu":
			hide_all()
			replay_menu.visible = true
		"play_replay_menu":
			replay_menu.play_select_replay_animation()
		"start_flashback":
			racing_minigame.pause_game(true)
		"finish_flashback":
			racing_minigame.pause_game(false)
		"show_result":
			hide_all()
			results.visible = true


func init_minigame():
	racing_minigame = racing_minigame_path.instantiate()
	add_child(racing_minigame)
	move_child(racing_minigame, 0)
	racing_minigame.game_finished.connect(_on_game_finished)
	racing_minigame.event_emitted.connect(_on_event_emitted)


func _on_credits_finished():
	credits.visible = false
	continue_prompt.show()


func hide_all():
	replay_menu.visible = false
	fallback.visible = false
	results.visible = false
	continue_prompt.visible = false
	credits.visible = false
