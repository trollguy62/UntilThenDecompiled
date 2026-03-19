extends SkitContainer

const Fader = preload("res://components/Fader/Fader.gd")

@onready var fader: Fader = Service.of("Fader")
@onready var ridel_state: StateContainer = Utils.get_state_container_of("RidelGonzales")

func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(name: String, value):
	if not is_running:
		return

	match name:
		"game_balloons":
			_start_game("game_balloons")
		"game_cups":
			_start_game("game_cups")
		"game_coin_toss":
			_start_game("game_coin_toss")


func _start_game(name: String):
	ridel_state.dict.set_value("mode","follow")
	await Utils.wait(0.5)
	await fader.fade_out()

	var dialogue = Story.substory_from_id("8.2a." + name)
	dialogue.start()
	await dialogue.finished

	ridel_state.dict.set_value("mode","roam")
	await Story.start_short("8.2a.Exploration_AfterGame")
