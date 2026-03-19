extends "res://ui/components/Game/Page.gd"

@onready var yes_btn = $HBox/YesBtn
@onready var no_btn = $HBox/NoBtn


func _enter():
	super._enter()
	yes_btn.pressed.connect(_on_yes_btn_pressed)
	no_btn.pressed.connect(_page_container.pop)



func _exit():
	super._exit()
	yes_btn.pressed.disconnect(_on_yes_btn_pressed)
	no_btn.pressed.disconnect(_page_container.pop)


func _on_yes_btn_pressed():
	Game.go_to_main_menu()
	PauseScreen.unpause()
	_page_container.pop()
