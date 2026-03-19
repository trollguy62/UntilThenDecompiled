extends "res://ui/components/Game/Page.gd"

signal confirmed
const D_PAD_BUTTONS = ["d_left", "d_up", "d_right", "d_down"]

@export var message: String = "":
	set(v):
		if not is_inside_tree():
			await ready
		message = v
		message_label.text = message

@onready var ok_btn = $HBox/OkBtn
@onready var message_label = $VBox/MessageLabel

func _ready():
	ok_btn.pressed.connect(_confirm)
	message_label.text = message

func _enter():
	super._enter()


func _exit():
	super._exit()
	confirmed.emit()


func _confirm():
	_page_container.pop()

func _input(event):
	for d_key in D_PAD_BUTTONS:
		if event.is_action_pressed(d_key) and get_viewport().gui_get_focus_owner() == null and visible:
			ok_btn.grab_focus()
