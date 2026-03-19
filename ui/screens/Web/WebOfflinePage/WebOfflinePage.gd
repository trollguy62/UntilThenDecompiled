extends "res://ui/screens/Web/InternalWebPage.gd"

const WebDinoGame = preload("res://ui/screens/Web/WebOfflinePage/dinogame/WebDinoGame.gd")
const WebDinoGameScene = preload("res://ui/screens/Web/WebOfflinePage/dinogame/WebDinoGame.tscn")

@onready var game_viewport = $Margin/VBox/ViewportContainer/Viewport
@onready var game_viewport_container = $Margin/VBox/ViewportContainer
@onready var idle_timer = $IdleTimer

func _ready():
	super._ready()
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	loaded.connect(_on_loaded)
	idle_timer.timeout.connect(play_delayed_idle)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		control_game()


func control_game():
	var game: WebDinoGame = game_viewport.get_child(0)
	if game == null:
		return

	if not game.started:
		game_viewport_container.modulate.a = 1.0
		game.start()
	elif game.is_over:
		game_viewport.remove_child(game)
		game.queue_free()

		game = WebDinoGameScene.instantiate()
		game.start_now = true
		game_viewport.add_child(game)

func _on_focus_entered():
	var game: WebDinoGame = game_viewport.get_child(0)
	game.stop_idle()
	idle_timer.stop()
	game_viewport_container.modulate.a = 0.75

func _on_focus_exited():
	game_viewport_container.modulate.a = 1.0
	idle_timer.start()

func _on_loaded():
	idle_timer.start()

func play_delayed_idle():
	var game: WebDinoGame = game_viewport.get_child(0)
	game.play_idle()
