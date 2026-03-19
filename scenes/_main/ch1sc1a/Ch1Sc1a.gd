extends Scene

@onready var minigame_button_up = $Main/MinigameButtonUp


func _ready():
	minigame_button_up.visible = false

	minigame_button_up.finished.connect(_on_minigame_button_up_finished)

	Story.emitted.connect(_on_story_emitted)


func _on_minigame_button_up_finished():
	Story.emit("minigame_button_up_finished")


func _on_story_emitted(name: String, value):
	match name:
		"cross_fade_mid1_mid2":
			$Audio/ACF_Mid1_Mid2.cross_fade()
