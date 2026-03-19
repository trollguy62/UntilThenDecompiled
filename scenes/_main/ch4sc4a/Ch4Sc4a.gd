extends Scene

const TriggerArea = preload("res://components/TriggerArea.gd")
const InteractiveArea = preload("res://components/InteractiveArea/InteractiveArea.gd")

@onready var minigame_videoke = $Main/MinigameVideoke
@onready var bgm = $Audio/Music/MusicRelaxing

func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emit)


func _on_story_emit(emit: String, value):
	match emit:
		"minigame_videoke":
			var tween = get_tree().create_tween()
			tween.tween_property(bgm, "volume", 0.0, 2.5)
		"videoke_exited":
			var tween = get_tree().create_tween()
			tween.tween_property(bgm, "volume", 1.0, 2.5)
			minigame_videoke.karaoke.stop()
		"stop_videoke":
			minigame_videoke.karaoke.stop()
