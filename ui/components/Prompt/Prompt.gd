extends CenterContainer

enum Response {
	YES_BTN,
	NO_BTN
}

signal answered(state)

@export var default_focus: Response = Response.YES_BTN
@export var message: String = "This is a prompt message":
	set(v):
		if not is_inside_tree():
			await ready

		message = v
		message_lbl.text = message

@onready var yes_btn = $VBoxContainer/HBox/YesBtn
@onready var no_btn = $VBoxContainer/HBox/NoBtn
@onready var message_lbl = $VBoxContainer/Message

func _ready():
	yes_btn.pressed.connect(_on_yes_btn_pressed)
	no_btn.pressed.connect(_on_no_btn_pressed)

	await Utils.wait(0.1)

	if default_focus == Response.YES_BTN:
		yes_btn.grab_focus()
	else:
		no_btn.grab_focus()

func _on_yes_btn_pressed():
	answered.emit(true)

func _on_no_btn_pressed():
	answered.emit(false)
