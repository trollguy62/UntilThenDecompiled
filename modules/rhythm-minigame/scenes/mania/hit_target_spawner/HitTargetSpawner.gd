extends Node2D

signal new_result(result, column)

@export var single_note_scene: PackedScene
@export var hold_note_scene: PackedScene

@export var left_texture: Texture
@export var down_texture: Texture
@export var up_texture: Texture
@export var right_texture: Texture

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const HitInput = preload("res://modules/rhythm-minigame/classes/input/HitInput.gd")
const OsuHitObject = preload("res://modules/rhythm-minigame/classes/beatmap/OsuHitObject.gd")
const RhythmGameConstants = preload("res://modules/rhythm-minigame/utils/RhythmGameConstants.gd")

var lead_in_time: float = 1000.0  #in ms
var column_height: float = 0.0
var arrow_frame: Node2D

@onready var hit_columns: Array = get_children()


func _ready():
	assert(left_texture && down_texture && up_texture && right_texture)


func spawn(ho: OsuHitObject):
	assert(ho.column < hit_columns.size())

	var hit_note
	if ho.type & (1 << OsuHitObject.TYPE_HIT_CIRCLE) != 0:
		hit_note = single_note_scene.instantiate()
	elif ho.type & (1 << OsuHitObject.TYPE_HOLD) != 0:
		hit_note = hold_note_scene.instantiate()
	else:
		return

	hit_note.hit_object = ho
	hit_note.new_result.connect(_on_new_result)

	match ho.column:
		RhythmGameConstants.COLUMN.UP:
			hit_note.texture = up_texture
		RhythmGameConstants.COLUMN.DOWN:
			hit_note.texture = down_texture
		RhythmGameConstants.COLUMN.RIGHT:
			hit_note.texture = right_texture
		RhythmGameConstants.COLUMN.LEFT:
			hit_note.texture = left_texture

	hit_note.lead_in_msec = lead_in_time
	hit_note.speed = column_height / (lead_in_time / 1000.0)
	hit_note.column = ho.column
	hit_note.arrow_frame = arrow_frame
	hit_columns[ho.column].add_child(hit_note)


func handle(hit_input: HitInput):
	var column: int = hit_input.column
	var column_node: Node = hit_columns[column]

	if column_node.get_child_count() > 0:
		var hit_note = column_node.get_child(0)
		hit_note.handle(hit_input)


func _on_new_result(hit_result: HitResult, column):
	new_result.emit(hit_result, column)
