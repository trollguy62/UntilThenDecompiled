extends HBoxContainer

signal playthrough_selected(idx)

@onready var buttons = [$Button, $Button2, $Button3]


func _ready():
	for b in buttons:
		b.pressed.connect(_on_playthrough_button_pressed.bind(buttons.find(b)))

	buttons[Game.playthrough - 1].button_pressed = true


func _on_playthrough_button_pressed(idx: int = 0):
	playthrough_selected.emit(idx)
