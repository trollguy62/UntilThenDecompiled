extends Control

signal fallen
signal rain
signal cue_butterfly
signal cue_end

const ANIM_COUNT = 7

@onready var anim_player = $AnimationPlayer
@onready var music = $Music

@onready var next_delay = float(Game.get_scene_param("next_delay", 0))
@onready var next_scene_key = str(Game.get_scene_param("next_scene_key", ""))
@onready var next_scene_no_load_screen = Game.get_scene_param("next_scene_no_load_screen", false)

func _play():
	music.play()
	await Utils.wait(1.4)

	for i in range(ANIM_COUNT):
		anim_player.play(str(i + 1))
		await anim_player.animation_finished
	
	await Utils.wait(3.0)
