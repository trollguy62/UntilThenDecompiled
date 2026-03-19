extends "res://ui/components/Game/Page.gd"

signal resume_pressed

@onready var settings_page = $PageHolder/SettingsPage
@onready var quit_to_menu_page = $PageHolder/QuitToMenuPage
@onready var quit_game_page = $PageHolder/QuitGamePage

@onready var resume_btn = $ResumeBtn
@onready var settings_btn = $SettingsBtn
@onready var quit_to_menu_btn = $QuitToMenuBtn
@onready var quit_game_btn = $QuitGameBtn


func _ready():
	Game.paused_changed.connect(_on_paused_changed)
	resume_btn.pressed.connect(_on_resume_btn_pressed)
	settings_btn.pressed.connect(_push_page.bind(settings_page))
	quit_to_menu_btn.pressed.connect(_push_page.bind(quit_to_menu_page))
	quit_game_btn.pressed.connect(_push_page.bind(quit_game_page))

	if OS.get_name() == "Prospero":
		quit_game_btn.visible = false


func _on_paused_changed(paused: bool):
	if paused:
		resume_btn.grab_focus()


func _on_resume_btn_pressed():
	resume_pressed.emit()


func _push_page(page):
	_page_container.push(page)
