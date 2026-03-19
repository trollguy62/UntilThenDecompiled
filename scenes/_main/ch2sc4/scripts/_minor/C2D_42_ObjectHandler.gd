extends Node

const ClickableArea2D = preload("res://components/ClickableArea2D.gd")
const Presenter = preload("res://components/Presenter/Presenter.gd")

@export var full_texture: Texture
@export var short_knot = ""

@onready var area = Utils.get_child_of_type(self, "Area2D") as ClickableArea2D
@onready var scene_manager = Service.of("SceneManager") as SceneManager
@onready var presenter = Service.of("Presenter") as Presenter
@onready var sfx_pickup = $SFXPickup
@onready var sfx_drop = $SFXDrop

var presenter_active = false


func _ready():
	area.pressed.connect(_on_area_pressed)
	presenter.is_shown.connect(_on_presenter_shown)
	presenter.is_hidden.connect(_on_presenter_hidden)



func _on_area_pressed():
	if presenter_active:
		return

	presenter_active = true
	await presenter.present(full_texture, true)
	# TODO: Determine if this is really necessary
	# await scene_manager.start_short(short_knot)


func _on_presenter_shown():
	sfx_pickup.play()
	presenter_active = true
	pass


func _on_presenter_hidden():
	sfx_drop.play()
	presenter_active = false
