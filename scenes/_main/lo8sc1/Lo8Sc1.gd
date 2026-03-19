extends Scene

@onready var minigame_bulletin_board = $Main/BoardLayer/MinigameBulletinBoard

var disable_pins = false
var pins_removed = 0

func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	minigame_bulletin_board.disappear_requested.connect(_on_bulletin_board_disappear_requested)
	minigame_bulletin_board.pin_removed.connect(_on_bulletin_board_pin_removed)
	Game.has_internet = false


func _on_story_emitted(name: String, value):
	match name:
		"show_bulletin_board":
			fader.fade_between(_show_bulletin_board)
		"hide_bulletin_board":
			_on_bulletin_board_disappear_requested()
		"disable_pins":
			_disable_pins(value)
		"reset_button_pins":
			_reset_button_pins()
		"bulletin_board_poster_psa_1":
			Story.start_short("lo.8.1.poster_psa_1")
		"bulletin_board_poster_psa_2":
			Story.start_short("lo.8.1.poster_psa_2")
		"bulletin_board_poster_curfew":
			Story.start_short("lo.8.1.poster_curfew")
		"bulletin_board_poster_donations":
			Story.start_short("lo.8.1.poster_donations")
		"bulletin_board_poster_promote":
			Story.start_short("lo.8.1.poster_promote")
		"bulletin_board_poster_stock":
			Story.start_short("lo.8.1.poster_stock")
		"bulletin_board_poster_wanted":
			Story.start_short("lo.8.1.poster_wanted")




func _show_bulletin_board():
	minigame_bulletin_board.appear()
	scene_manager.change_shot("bulletin_board")

func _hide_bulletin_board():
	minigame_bulletin_board.disappear()
	scene_manager.change_shot("CamF1")


func _on_bulletin_board_disappear_requested():
	fader.fade_between(_hide_bulletin_board)


func _on_bulletin_board_pin_removed():
	var short_id = ""
	if disable_pins:
		short_id = "lo.8.1.decline_removing_pins"
	else :
		pins_removed +=1
		match minigame_bulletin_board.pins_removed:
			1:
				short_id = "lo.8.1.removed_1_pin"
			2:
				short_id = "lo.8.1.removed_2_pins"
			3:
				short_id = "lo.8.1.removed_3_pins"

	if short_id != "":
		Story.start_short(short_id)
		short_id = ""

	if pins_removed == minigame_bulletin_board.pins.get_child_count():
		Game.dist_platform.unlock_achievement("ACH_MATIGAS_ULO")
		Game.savegame.save_board_cleared(key)


func _disable_pins(value):
	disable_pins = value
	for pin in minigame_bulletin_board.pins.get_children():
		pin.removable = !value

func _reset_button_pins():
	for pin in minigame_bulletin_board.pins.get_children():
		pin.btn.disabled = false
		pin.btn.release_focus()

func exit_scene():
	super.exit_scene()
	Game.has_internet = true
