extends "res://ui/components/Game/Page.gd"

signal play_btn_pressed

@onready var scene_select_page = $PageHolder/SceneSelectPage
@onready var settings_page = $PageHolder/SettingsPage
@onready var quit_game_page = $PageHolder/QuitGamePage

@onready var play_btn = $Panel/Actions/PlayBtn
@onready var scene_select_btn = $Panel/Actions/SceneSelectBtn
@onready var settings_btn = $Panel/Actions/SettingsBtn
@onready var quit_game_btn = $Panel/Actions/QuitGameBtn


func _ready():
	play_btn.pressed.connect(func(): play_btn_pressed.emit())
	scene_select_btn.pressed.connect(_push_page.bind(scene_select_page))
	settings_btn.pressed.connect(_push_page.bind(settings_page))
	quit_game_btn.pressed.connect(_push_page.bind(quit_game_page))

	play_btn.text = "MAIN_MENU_START" if Game.is_new_game() else "MAIN_MENU_CONTINUE"
	
	if OS.get_name() == "Prospero":
		quit_game_btn.visible = false


func _process(_delta):
	if is_inside_tree() and Input.is_action_just_pressed("pause") and OS.get_name() != "Prospero":
		_push_page(quit_game_page)


func _push_page(page):
	_page_container.push(page)
