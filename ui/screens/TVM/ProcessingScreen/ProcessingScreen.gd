extends Control

const SuccessScreen = preload("../SuccessScreen/SuccessScreen.tscn")

const DELAY = 3.0

@onready var tvm = find_parent("TVM")
var change: int = 0


func _ready():
	tvm.process_ticket.play()
	await Utils.wait(DELAY)
	_goto_success_screen()


func _goto_success_screen():
	var screen = SuccessScreen.instantiate()
	screen.change = change
	tvm.goto(screen)
