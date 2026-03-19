extends "res://ui/components/Game/FocusableControl.gd"

@onready var pos = position

var t := 99999.9
var k := 32.0


func _enter_tree():
	mute_tick = true


func _ready():
	pressed.connect(_on_pressed)


func _process(delta):
	t += delta
	var dy = sin(k * t) / (k * t) * 50
	if t < 2.0:
		position = pos + Vector2(0, dy)


func _on_pressed():
	shake()


func shake():
	t = PI / k
