extends Control

const MainMenuBG = preload("res://scenes/_main/lopost/MainMenuBG.tscn")


func _ready():
	if Game.ng_plus:
		$MainMenu.standalone = false

		var post_bg = MainMenuBG.instantiate()
		add_child(post_bg)
		move_child(post_bg, 0)

		await Utils.wait_frames(10)
		$Background.queue_free()
