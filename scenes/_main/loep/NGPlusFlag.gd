extends Node

func _ready():
	(get_parent() as SkitContainer).skit_finished.connect(func():
		Game.ng_plus = true
	)
