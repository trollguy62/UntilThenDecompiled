extends MarginContainer

@onready var option_yes = $VBox/YesBtn
@onready var option_no = $VBox/NoBtn
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

var selected_option
var active = false
var alpha_values = [1, 0]


func _ready():
	option_yes.focus_entered.connect(_on_yes_focus_entered)
	option_no.focus_entered.connect(_on_no_focus_entered)
	timer.timeout.connect(_on_timer_timeout)


func show():
	Game.playthrough = 2
	visible = true
	option_yes.grab_focus()
	active = true
	timer.start(0.4)


func _on_yes_focus_entered():
	selected_option = option_yes


func _on_no_focus_entered():
	selected_option = option_no


func _process(delta):
	if active and visible:
		if Input.is_action_just_pressed("ui_accept"):
			if selected_option == option_yes:
				Story.emit("end")
				visible = false
			else:
				animation_player.play("quick_glitch")
				Game.savegame.unlock_scene("6.1a")
				Game.savegame.current_scene_key = "6.1a"
				Game.save_savegame()
				await animation_player.animation_finished
				Game.go_to_main_menu()

		if Input.is_action_just_pressed("ui_up"):
			option_yes.grab_focus()

		if Input.is_action_just_pressed("ui_down"):
			option_no.grab_focus()

		if Input.is_action_just_pressed("ui_up"):
			option_yes.grab_focus()

		if Input.is_action_just_pressed("ui_down"):
			option_no.grab_focus()


func _on_timer_timeout():
	option_yes.self_modulate.a = alpha_values[0]
	option_no.self_modulate.a = alpha_values[0]
	alpha_values.reverse()
