extends Node2D

signal game_finished

@export var player_scene : PackedScene

const enemy = preload("res://scenes/_main/ch2sc5a/MinigamePlatformer/scripts/Enemy.gd")

@onready var player = $Player
@onready var hbox = $HBoxContainer
@onready var finish = $Finish
@onready var anim_done = $Banner/AnimationPlayer
@onready var bgm = $BGM


func _ready():
	player.dead.connect(_on_player_death)
	finish.finished.connect(_on_finished)
	play(false)


# enable/disable the minigame
func play(flag: bool):
	if flag:
		bgm.play()
	else:
		bgm.stop()

	for node in get_children():
		if node.get_script() != null:
			node.set_physics_process(flag)
			node.set_process(flag)

			if flag and node.get_script() == enemy:
				node.enable()


func _on_player_death(is_cliff: bool):
	if hbox.get_child_count() > 0:
		var wait_time = 0.5 if is_cliff else 2
		await Utils.wait(wait_time)
		player.queue_free()

		var new_player = player_scene.instantiate()
		player = new_player
		player.dead.connect(_on_player_death)
		player.position = Vector2(227.998, 400.698)
		add_child(player)

		hbox.get_child(0).queue_free()
	else:
		_on_finished()


func _on_finished():
	player.allow_control = false
	if hbox.get_child_count() > 0:
		anim_done.play("finish")
	else:
		anim_done.play("gameover")
	await anim_done.animation_finished
	game_finished.emit()
