extends AnimatedSprite2D

@export var state_container: StateContainer


func _ready():
	state_container.flags.changed.connect(func():
		var talking = state_container.flags.has("$talk")
		play("talk" if talking else "idle")
	)
