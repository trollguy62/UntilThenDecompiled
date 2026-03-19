extends Node

@onready var metronome = get_parent()
@onready var focus = $Focus
@onready var input_blocker = $InputBlocker


func _ready():
	metronome.back_button_clicked.connect(_on_back_button_clicked)


func _process(delta):
	input_blocker.visible = not focus.active

	if metronome.visible != focus.active:
		if metronome.visible:
			focus.push()
		else:
			focus.pop()


func _on_back_button_clicked():
	Story.emit("metronome_back")
