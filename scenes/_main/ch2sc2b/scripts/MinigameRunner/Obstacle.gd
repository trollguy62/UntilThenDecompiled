extends Node3D

signal entered(npc)
signal exited

enum PanDirection { left, right }

@export var pan_direction: PanDirection
@export var reaction_dodge: Texture
@export var reaction_miss: Texture
@export var reaction_sfx_dodge: AudioStream
@export var reaction_sfx_miss: AudioStream
@export var short_action_choice: String
@export var correct_choice: int = 1
@export var short_knot_dodge: String
@export var short_knot_miss: String

@onready var area: Area3D = $Area
@onready var sprite: AnimatedPaper3D = $Sprite


func _ready():
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func _on_area_entered(other):
	entered.emit(self)


func _on_area_exited(other):
	exited.emit()
