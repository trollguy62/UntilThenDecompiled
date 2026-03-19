extends Node

@onready var main_menu = $MainMenu
@onready var alarm = $Alarm
@onready var alarm_hint = $AlarmHint
@onready var start_btn = $StartBtn

@onready var _scene = Utils.get_root_scene()

var _skit_container: SkitContainer

var _with_main_menu := false


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container

	main_menu.visible = true
	start_btn.visible = false

	alarm_hint.playing = false

	main_menu.game_started.connect(_on_game_started)
	start_btn.pressed.connect(_alarm_buzz)
	_skit_container.emitted.connect(_on_skit_container_emitted)

	_scene.pausable = false
	_with_main_menu = Game.get_scene_param("with_main_menu", false)

	if not _with_main_menu:
		_on_game_started()


func _on_game_started():
	_scene.pausable = true
	main_menu.queue_free()
	start_btn.visible = true
	start_btn.call_deferred("grab_focus")

	if _with_main_menu:
		_alarm_buzz()
		start_btn.shake()


func _alarm_buzz():
	alarm.play()

	Story.emit("alarm_buzz")
	_skit_container.emit_local("alarm_buzz")

	if not alarm_hint.playing:
		alarm_hint.play("notice", true)


func _on_skit_container_emitted(name: String, value):
	if name == "cross_fade_intro_mid1":
		$ACF_Intro_Mid1.cross_fade()

func _input(event):
	if start_btn.is_visible_in_tree():
		if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
			start_btn.call_deferred("grab_focus")
