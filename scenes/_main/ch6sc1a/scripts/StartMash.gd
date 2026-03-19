extends Node

@onready var main_menu = $MainMenu
@onready var start_btn = $StartBtn

@onready var _scene = Utils.get_root_scene()

var _skit_container: SkitContainer

var _with_main_menu := false


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container

	main_menu.visible = true
	start_btn.visible = false

	main_menu.game_started.connect(_on_game_started)
	_skit_container.emitted.connect(_on_skit_container_emitted)

	_scene.pausable = false
	_with_main_menu = Game.get_scene_param("with_main_menu", false)

	if not _with_main_menu:
		_on_game_started()


func _on_game_started():
	_scene.pausable = true
	main_menu.visible = false
	start_btn.visible = true
	start_btn.grab_focus()

	if _with_main_menu:
		_mash()
		start_btn.shake()


func _mash():
	_skit_container.emit_local("mash")


func _on_skit_container_emitted(name: String, value):
	if name == "hide_start_btn":
		start_btn.visible = false


#FIXME: hack
func _input(event):
	if event.is_action_pressed("c_interact") or event.is_action_pressed("interact"):
		if get_viewport().gui_get_focus_owner() != start_btn:
			start_btn.grab_focus()
