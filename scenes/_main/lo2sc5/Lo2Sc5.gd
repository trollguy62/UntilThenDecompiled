extends Scene

const TriggerArea = preload("res://components/TriggerArea.gd")
const InteractiveArea = preload("res://components/InteractiveArea/InteractiveArea.gd")

@onready var minigame_map = $Skits/FreeRoam/Root2D/MinigameMap

func _ready():
	super._ready()
	minigame_map.finished.connect(Story.emit.bind("map_minigame_finished"))
	minigame_map.wrong_stick.connect(_on_map_wrong_stick)
	minigame_map.wrong_stick.connect(_on_map_correct_stick)
	Story.emitted.connect(_on_story_emit)


func _on_story_emit(emit: String, value):
	match emit:
		"start_minigame_map":
			minigame_map.start()


func _on_map_wrong_stick():
	var short_knot = "map_wrong_stick"
	var scene_id = scene_manager.scene_id
	var id = "%s.%s" % [scene_id, short_knot]
	Story.start_short(id)


func _on_map_correct_stick():
	#unused
	pass
