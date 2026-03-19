extends "res://ui/components/Game/Page.gd"

@onready var message = $Message
@onready var yes_btn = $HBox/YesBtn
@onready var no_btn = $HBox/NoBtn


func _enter():
	super._enter()
	yes_btn.pressed.connect(get_tree().quit)
	no_btn.pressed.connect(_page_container.pop)

	message.text = "QUIT_GAME_PROG" if Utils.has_root_scene() else "QUIT_GAME"


func _exit():
	super._exit()
	yes_btn.pressed.disconnect(get_tree().quit)
	no_btn.pressed.disconnect(_page_container.pop)
