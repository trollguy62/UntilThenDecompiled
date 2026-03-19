extends SkitContainer

const AswangWorld = preload("res://scenes/_main/ch3sc2a/Minigames/AswangWorld2/AswangWorld.tscn")

@onready var aswang_world = AswangWorld.instantiate()


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	aswang_world.game_finished.connect(_on_aswang_world_game_finished)


func _on_story_emitted(s: String, value):
	match s:
		"start_minigame_dart":
			var dialogue = Story.substory_from_id("3.2b.game_darts")
			dialogue.start()
			await dialogue.finished
			Story.emit("minigame_dart_finished")

		"load_minigame_aswang_world":
			$Root2D/MinigameAswangWorld.add_child(aswang_world)
			$Root2D/MinigameAswangWorld/Chibis.reparent(aswang_world.get_node("HUD/PauseIndependentUI"))

		"start_minigame_aswang_world":
			Game.record_replay_pause()
			aswang_world.start_game()

		"kill_minigame_aswang_world":
			Game.record_replay_resume()
			aswang_world.queue_free()


func _on_aswang_world_game_finished(win_state: int):
	Store.set_value("state://ch3sc2b/aswang_world_win_state", win_state)
	Story.emit("aswang_world_game_finished")

	if win_state == 1:
		Game.dist_platform.unlock_achievement("ACH_ASWANG_WIN")
