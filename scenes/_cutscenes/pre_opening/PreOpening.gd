extends "res://scenes/_cutscenes/CutScene.gd"

const ANIM_COUNT = 7

@onready var anim_player = $AnimationPlayer
@onready var music = $Music

@onready var next_delay = float(Game.get_scene_param("next_delay", 0))
@onready var next_scene_key = str(Game.get_scene_param("next_scene_key", ""))
@onready var next_scene_no_load_screen = Game.get_scene_param("next_scene_no_load_screen", false)

var _next_called := false


func _ready():
	super._ready()

	if Game.first_run:
		self.skippable = false

	await _play()
	_next()


func _play():
	music.play()
	await Utils.wait(1.4)

	for i in range(ANIM_COUNT):
		anim_player.play(str(i + 1))
		await anim_player.animation_finished
	
	await Utils.wait(3.0)


func _next():
	if _next_called:
		return
	else:
		_next_called = true
	
	if Game.first_run:
		Game.first_run = false

	if next_delay > 0:
		await Utils.wait(next_delay)

	if Game.is_scene_key_valid(next_scene_key):
		Game.to_scene_key(next_scene_key, {}, next_scene_no_load_screen)
	else:
		Game.go_to_main_menu()
