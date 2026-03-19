extends Control

signal ui_animation_finished(anim_name)

@onready var anim = $AnimationPlayer
@onready var tween = Threen.new()
@onready var car = $ReadyMenu/Panel/Car/CarSprite
@onready var menu_theme = $RacingMenuTheme


func _ready():
	add_child(tween)
	anim.animation_finished.connect(on_animation_finished)
	visibility_changed.connect(_on_visibility_changed)


func play_select_replay_animation():
	anim.play("select_replay")


func play_lobby_waiting_animation():
	anim.play("waiting_for_cathy")
	tween.interpolate_property(car, "position:x", 420, -30, 3)
	tween.repeat = true
	tween.start()


func on_animation_finished(anim_name):
	if anim_name == "select_replay":
		play_lobby_waiting_animation()
	elif anim_name == "waiting_for_cathy":
		ui_animation_finished.emit("replay_menu_finished")


func _on_visibility_changed():
	if not menu_theme:
		return

	menu_theme.playing = self.visible
