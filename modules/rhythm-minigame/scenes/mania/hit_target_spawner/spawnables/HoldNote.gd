extends Node2D

signal new_result(hit_result, column)

@export var speed = 1000.0  #px/s
@export var lead_in_msec = 1000.0  #ms
@export var texture: Texture

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const HitInput = preload("res://modules/rhythm-minigame/classes/input/HitInput.gd")
const OsuHitObject = preload("res://modules/rhythm-minigame/classes/beatmap/OsuHitObject.gd")

#FIXME: used only to account for the slight inaccuracy in length calcs
const LENGTH_COMPENSATION_PX = -12.0

var hit_object: OsuHitObject
var _has_head_result = false
var _has_tail_result = false
var _timestamp_spawned_msec = 0

@onready var tail = $Tail
@onready var head = $Head
@onready var bridge = $Bridge
@onready var tween = Threen.new()

var tail_end_time
var is_hittable: bool
var column
var arrow_position_y = 0
var arrow_frame
var original_size


func _ready():
	add_child(tween)
	if texture:
		tail.texture = texture
		head.texture = texture

	var arrow_local_pos = self.to_local(arrow_frame.position)
	arrow_position_y = arrow_local_pos.y

	_timestamp_spawned_msec = Time.get_ticks_msec()
	tail_end_time = int(hit_object.objectParams.split(":", true, 1)[0])
	var tail_lifetime = tail_end_time - hit_object.time

	tail.position.y = -speed * tail_lifetime / 1000.0
	tail.lead_in_msec = lead_in_msec
	tail.base_lifetime = tail_lifetime
	tail.force_miss_on_input_change = true
	tail.target_hit_input = HitInput.new(tail_end_time, hit_object.column, false)
	tail.is_head_or_tail = true

	bridge.size.y = abs(head.position.y - tail.position.y)
	bridge.position.y = -sign(speed) * bridge.size.y
	bridge.scale.y = sign(speed)
	original_size = bridge.size.y

	head.target_hit_input = HitInput.new(hit_object.time, hit_object.column, true)
	head.lead_in_msec = lead_in_msec
	head.is_head_or_tail = true

	is_hittable = true
	head.new_result.connect(_on_new_head_result)
	tail.new_result.connect(_on_new_tail_result)


func _process(delta):
	position.y += speed * delta

	if _has_head_result and is_hittable:
		var dist = abs(position.y) - abs(arrow_position_y)
		bridge.size.y = original_size - dist + LENGTH_COMPENSATION_PX


func _get_time_elapsed_msec():
	return Time.get_ticks_msec() - _timestamp_spawned_msec


func handle(hi: HitInput):
	if !_has_head_result:
		head.check_result(hi)
	elif !_has_tail_result:
		tail.check_result(hi)


func _on_new_head_result(hit_result: HitResult):
	if not _has_head_result:
		new_result.emit(hit_result, self.column)

	_has_head_result = true
	if hit_result.type == HitResult.HIT_RESULT_MISS:
		disable_note()


func _on_new_tail_result(hit_result: HitResult):
	if not _has_tail_result:
		new_result.emit(hit_result, self.column)

	_has_tail_result = true
	disable_note()
	if hit_result.type != HitResult.HIT_RESULT_MISS or tail.has_hit_miss_threshold():
		queue_free()


func disable_note():
	if not is_hittable:
		return
	tween.interpolate_property(self, "modulate:a", 1.0, 0.3, 0.1)
	tween.start()
	is_hittable = false
