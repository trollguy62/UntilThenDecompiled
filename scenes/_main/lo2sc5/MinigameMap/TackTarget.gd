extends Marker2D

const Tack = preload("./Tack.gd")

signal correct_stick
signal wrong_stick

@export var id: int = 0

func stick(tack):
	tack.set_input(false)
	tack.global_position = global_position
