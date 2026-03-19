extends CanvasLayer

signal time_up

@export var starting_time = 10

@onready var timer = $Timer
@onready var label = $Label


func _ready():
	timer.timeout.connect(_on_timedout)
	label.text = str(starting_time)


func _on_timedout():
	var time = int(label.text) - 1
	label.text = str(time)

	if time == 0:
		time_up.emit()
		timer.stop()


func reset_time():
	label.text = str(starting_time)
	timer.start()
