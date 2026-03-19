extends Node2D

signal finished

@onready var anim_player = $AnimationPlayer
@onready var focus = $Focus

@onready var sfx_slide_1 = $Slide1
@onready var sfx_slide_2 = $Slide2
@onready var sfxs_slide = [sfx_slide_1, sfx_slide_2]


func _ready():
	focus.push()

	for i in range(8):
		await Utils.wait(0.5)

		while not (Input.is_action_just_pressed("interact") and focus.active):
			await get_tree().process_frame

		anim_player.play("slide_%d" % (i + 1))
		_play_random_sfx_slide()
		await anim_player.animation_finished

	finished.emit()
	focus.pop()


func _play_random_sfx_slide():
	var sfx_slide = sfxs_slide[randi() % sfxs_slide.size()]
	sfx_slide.play()
