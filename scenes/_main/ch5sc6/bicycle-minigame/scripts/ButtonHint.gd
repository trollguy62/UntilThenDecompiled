extends TextureButton


func _ready():
	$Timer.timeout.connect(_on_timer_timeout)
	visible = true


var t = 0


func _on_timer_timeout():
	button_pressed = not button_pressed


func simulate_press():
	button_pressed = false
	await get_tree().create_timer(0.1).timeout
	button_pressed = true
