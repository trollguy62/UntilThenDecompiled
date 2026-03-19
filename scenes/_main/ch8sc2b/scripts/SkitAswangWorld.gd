extends SkitContainer

@onready var aswang_world = $Root2D/MinigameAswangWorld/ViewportContainer/Viewport/AswangWorld
@onready var chibis = $Root2D/MinigameAswangWorld/Chibis
@onready var sprites_post_abort = $Root2D/MinigameAswangWorld/SpritesPostAbort


func _ready():
	super._ready()

	Story.emitted.connect(_on_story_emitted)
	chibis.reparent(aswang_world.get_node("HUD/PauseIndependentUI"))

	sprites_post_abort.visible = false


func _on_story_emitted(s: String, value):
	match s:
		"prestart_minigame_aswang_world":
			aswang_world.play_bgm_tutorial()

		"start_minigame_aswang_world":
			aswang_world.start_game()

		"abort_minigame_aswang_world":
			aswang_world.abort_game()
			chibis.queue_free()
			sprites_post_abort.visible = true
