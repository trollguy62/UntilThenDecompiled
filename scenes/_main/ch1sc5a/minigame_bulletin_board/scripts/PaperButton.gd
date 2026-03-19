extends Button

@export var story_signal := ""


func _ready():
	pressed.connect(_on_pressed)


func _on_pressed():
	visible = false
	Story.emit(story_signal)
