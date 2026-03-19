extends Node2D

signal new_result(hit_result, column)

@export var speed = 1000.0  #px/s
@export var texture: Texture

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const HitInput = preload("res://modules/rhythm-minigame/classes/input/HitInput.gd")
const OsuHitObject = preload("res://modules/rhythm-minigame/classes/beatmap/OsuHitObject.gd")

var hit_object: OsuHitObject
var lead_in_msec = 1000.0  #ms
var is_hittable: bool
var column
var arrow_frame

@onready var tween = Threen.new()
@onready var target = $HitTarget


func _ready():
	add_child(tween)
	target.texture = texture
	target.lead_in_msec = lead_in_msec
	target.target_hit_input = HitInput.new(hit_object.time, hit_object.column, true)
	target.new_result.connect(_on_new_result)
	is_hittable = false


func _process(delta):
	position.y += speed * delta


func handle(hi: HitInput):
	target.check_result(hi)


func _on_new_result(hit_result: HitResult):
	is_hittable = false
	new_result.emit(hit_result, self.column)
	queue_free()
