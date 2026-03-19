extends Scene

const SkipHint = preload("res://scenes/_cutscenes/SkipHint.tscn")

const CONTROLLER_TEXT_OVERRIDE = "Press B to Skip"

@export var skippable := true:
	set(value):
		if skip_hint:
			skippable = value
			skip_hint.enabled = skippable
	get:
		return skippable


@onready var skip_hint = SkipHint.instantiate()


func _ready():
	super._ready()
	add_child(skip_hint)
	skip_hint.skipped.connect(_next, CONNECT_ONE_SHOT)

	self.skippable = Game.get_scene_param("skippable", skippable)
	self.pausable = false


func _next():
	pass
