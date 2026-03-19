extends Control

@export var p1_name = "ILoveSuckingLemons"
@export var p2_name = "hanabii14"

signal prematch_finished

@onready var anim_player = $AnimationPlayer
@onready var p1_mash_sprite = $Mash
@onready var p2_mash_sprite = $Mash2
@onready var p1_name_label = $P1Name
@onready var p2_name_label = $P2Name


func _ready():
	p1_mash_sprite.player_ready.connect(play_outro)


func play_intro():
	show()
	auto_ready_p2()


func play_outro():
	await Utils.wait(1.5)
	anim_player.play("outro")
	await anim_player.animation_finished
	prematch_finished.emit()


func mash():
	if is_visible_in_tree():
		p1_mash_sprite.mash()


func auto_ready_p2():
	p2_mash_sprite.mash(true)
