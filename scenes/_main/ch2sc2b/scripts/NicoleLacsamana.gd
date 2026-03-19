extends Node3D

signal collision_area_entered

const MinigameRunner = preload("res://scenes/_main/ch2sc2b/MinigameRunner.gd")

@export var enabled := false
@export var short_choice := "nicole_choices"

@export var click_sfx_path: NodePath
@export var slomo_sfx_path: NodePath

@onready var click_sfx = get_node(click_sfx_path)
@onready var slomo_sfx = get_node(slomo_sfx_path)

@onready var slomo_area = $SlomoArea
@onready var slomo_collider = $SlomoArea/CollisionShape
@onready var collision_area = $CollisionArea
@onready var collision_collider = $CollisionArea/CollisionShape

@onready var minigame_runner = Service.of("MinigameRunner") as MinigameRunner

var _slomo_enabled := false


func _ready():
	slomo_area.area_entered.connect(_on_slomo_area_entered)
	collision_area.area_entered.connect(_on_collision_area_entered)


func _process(delta):
	if enabled:
		translate(Vector3.RIGHT * delta * minigame_runner.scroll_speed)

	if _slomo_enabled:
		Engine.time_scale = 0.25


func _on_slomo_area_entered(area: Area3D):
	_slomo_enabled = true
	var short_id = "2.2b." + short_choice
	Story.start_short(short_id)

	click_sfx.play()
	slomo_sfx.play()


func _on_collision_area_entered(area: Area3D):
	_slomo_enabled = false
	collision_area_entered.emit()
