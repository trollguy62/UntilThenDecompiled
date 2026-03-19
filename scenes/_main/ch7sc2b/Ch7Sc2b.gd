extends Scene

const MinigameRunner = preload("res://scenes/_main/ch2sc2b/MinigameRunner.gd")

@onready var minigame_runner = Service.of("MinigameRunner") as MinigameRunner
@onready var nicole_lacsamana = $Characters/NicoleLacsamana
@onready var mark_state = $Characters/MarkBorja/State
@onready var mark_sprite = $Characters/MarkBorja/Sprite


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	minigame_runner.game_finished.connect(_on_minigame_runner_finished)
	minigame_runner.mark_tripped.connect(_on_minigame_mark_tripped)
	nicole_lacsamana.collision_area_entered.connect(_on_nicole_lacsamana_colliding)


func _on_story_emitted(name: String, value):
	match name:
		"start_minigame_runner":
			minigame_runner.start()
		"release_nicole":
			nicole_lacsamana.enabled = true


func _on_minigame_runner_finished():
	Story.emit("minigame_runner_finished")


func _on_nicole_lacsamana_colliding():
	Story.emit("nearly_crashing_into_nicole")


func _on_minigame_mark_tripped():
	mark_state.flags.add("trip")
	await get_tree().process_frame
	await mark_sprite.animation_finished
	mark_state.flags.remove("trip")
