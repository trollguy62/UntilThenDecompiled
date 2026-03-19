extends Scene


@onready var minigame_bulletin_board = $Main/MinigameBulletinBoard


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	minigame_bulletin_board.disappear_requested.connect(_on_bulletin_board_disappear_requested)
	minigame_bulletin_board.pin_removed.connect(_on_bulletin_board_pin_removed)
	minigame_bulletin_board.all_pins_removed.connect(_on_bulletin_board_all_pins_removed)


func _on_story_emitted(name: String, value):
	match name:
		"show_bulletin_board":
			fader.fade_between(_show_bulletin_board)
		"bulletin_board_poster_teacher":
			Story.start_short("1.5a.poster_teacher")
		"bulletin_board_poster_piano_club":
			Story.start_short("1.5a.poster_piano_club")
		"bulletin_board_poster_prom":
			Story.start_short("1.5a.poster_prom")


func _show_bulletin_board():
	minigame_bulletin_board.appear()


func _hide_bulletin_board():
	minigame_bulletin_board.disappear()


func _on_bulletin_board_disappear_requested():
	fader.fade_between(_hide_bulletin_board)


func _on_bulletin_board_pin_removed():
	var short_id = ""
	match minigame_bulletin_board.pins_removed:
		1:
			short_id = "1.5a.removed_1_pin"
		5:
			short_id = "1.5a.removed_5_pins"
		10:
			short_id = "1.5a.removed_10_pins"

	if short_id != "":
		Story.start_short(short_id)


func _on_bulletin_board_all_pins_removed():
	Story.start_short("1.5a.removed_all_pins")
	Game.dist_platform.unlock_achievement("ACH_MATIGAS_ULO")
	Game.savegame.save_board_cleared(key)
