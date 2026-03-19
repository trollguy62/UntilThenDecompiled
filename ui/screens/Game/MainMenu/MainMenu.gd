extends Control

signal game_started

const MainPage = preload("res://ui/components/Game/MainPage/MainPage.tscn")
const SettingsWarningPage = preload("res://ui/components/Game/SettingsWarningPage/SettingsWarningPage.tscn")

@export var standalone = true

@onready var tween = Threen.new()
@onready var music = $Music
@onready var background = $Background
@onready var page_container = $PageContainer

@onready var main_page = MainPage.instantiate()
@onready var bg_stylebox = background.get_theme_stylebox("panel")


func _ready():
	add_child(tween)

	page_container.page_stack_changed.connect(_on_page_stack_changed)
	main_page.play_btn_pressed.connect(_on_play_btn_pressed)

	await Utils.wait(0.5)
	page_container.push(main_page)

	if Game.ng_plus and not Game.savegame.ng_plus_shown_msg:
		Game.savegame.ng_plus_shown_msg = true

		while page_container.is_busy():
			await Utils.wait_frames(1)

		var ng_page = SettingsWarningPage.instantiate()
		ng_page.message = "NG_PLUS_MSG"
		page_container.push(ng_page)

	if standalone:
		await Utils.wait(0.2)
		music.play()


func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		if page_container.page_count > 1:
			page_container.pop()


func _on_play_btn_pressed():
	# Code for resuming activity on PS5
	if OS.get_name() == "Prospero":
		if Game.is_new_game():
			Game.dist_platform.StartActivity()
		else:
			Game.dist_platform.ResumeActivity()

	game_started.emit()
	Game.start()


func _on_page_stack_changed():
	var to_a = 48 if page_container.page_count == 1 else 200
	var to_c = Color(0, 0, 0, to_a / 255.0)

	tween.stop_all()
	tween.interpolate_property(
		bg_stylebox, "bg_color", bg_stylebox.bg_color, to_c, page_container.transition_duration
	)
	tween.start()
