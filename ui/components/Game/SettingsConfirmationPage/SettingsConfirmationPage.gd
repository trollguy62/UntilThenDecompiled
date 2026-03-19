extends "res://ui/components/Game/Page.gd"

signal confirmed
signal dismissed

@onready var seconds_label = $VBox/SecondsLabel
@onready var timer = $Timer

@onready var yes_btn = $HBox/YesBtn
@onready var no_btn = $HBox/NoBtn

var _is_confirmed := false


func _ready():
	yes_btn.pressed.connect(_confirm)
	no_btn.pressed.connect(_dismiss)
	timer.timeout.connect(_dismiss)


func _process(delta):
	seconds_label.text = "(%d)" % int(ceil(timer.time_left))


func _enter():
	super._enter()
	_is_confirmed = false
	timer.start()


func _exit():
	super._exit()
	timer.stop()

	if _is_confirmed:
		confirmed.emit()
	else:
		dismissed.emit()


func _confirm():
	_is_confirmed = true
	_page_container.pop()


func _dismiss():
	_is_confirmed = false
	_page_container.pop()
