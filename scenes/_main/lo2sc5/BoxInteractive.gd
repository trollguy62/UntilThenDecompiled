extends "res://components/Sprite2DMouseMovable.gd"

const Presenter = preload("res://components/Presenter/Presenter.gd")

@export var dissolve_after_short := true
@export var short_knot := ""

@onready var tween := Threen.new()

var _skit_container: SkitContainer

func _ready():
	super._ready()
	add_child(tween)
	clicked.connect(_on_clicked)


func _skit_ready(_skit_container: SkitContainer):
	self._skit_container = _skit_container


func _on_clicked():
	await _start_short()

	if dissolve_after_short:
		self.enabled = false
		self._dissolving = true

		tween.interpolate_property(self, "self_modulate", self_modulate, Color.TRANSPARENT, 1)
		tween.start()
		await tween.tween_completed
		queue_free()


func _start_short():
	if short_knot != "" and _skit_container != null and is_instance_valid(_skit_container):
		await _skit_container.start_short(short_knot)
