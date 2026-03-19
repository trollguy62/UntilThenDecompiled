extends ColorRect

@onready var timer = $Timer


func _ready():
	visible = false
	timer.one_shot = true

	timer.timeout.connect(_on_timeout)
	_on_timeout()


func _on_timeout():
	visible = not visible and not Game.savegame.ng_plus and Game.playthrough == 3

	var duration = randf_range(0.1, 1) if visible else randf_range(1, 5)
	timer.start(duration)
