extends "res://components/Sprite2DMouseMovable.gd"

const SHORT_PREFIX = "ParentsRoom_box_"
const Presenter = preload("res://components/Presenter/Presenter.gd")

@export var dissolve_after_short := true

@onready var tween := Threen.new()
@onready var presenter = Service.of("Presenter") as Presenter

var _skit_container: SkitContainer

func _ready():
	super._ready()
	add_child(tween)
	clicked.connect(_on_clicked)
	presenter.is_shown.connect(_on_presenter_shown)
	presenter.is_hidden.connect(_on_presenter_hidden)

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
	if _skit_container != null and is_instance_valid(_skit_container):
		await _skit_container.start_short(SHORT_PREFIX + name)


func _on_presenter_shown():
	enabled = false


func _on_presenter_hidden():
	enabled = true
