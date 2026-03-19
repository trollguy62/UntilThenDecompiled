extends Panel

signal new_result(result)

const HitInput = preload("../../classes/input/HitInput.gd")
const HitResult = preload("../../classes/judgment/HitResult.gd")
const HitJudge = preload("../../classes/judgment/HitJudge.gd")
const RhythmGameConstants = preload("../../utils/RhythmGameConstants.gd")

@export var force_miss_on_input_change = false
@export var hold_line_scene: PackedScene
@export var style_normal: StyleBoxFlat
@export var style_hold: StyleBoxFlat

@export var textures = {
	"left": null,
	"down": null,
	"up": null,
	"right": null,
}

@export var effects = {HitResult.HIT_RESULT_GREAT: null, HitResult.HIT_RESULT_PERFECT: null}

@export var hit_sfxs = {HitResult.HIT_RESULT_GREAT: null, HitResult.HIT_RESULT_PERFECT: null}

@export var hold_sfx: AudioStream

#FIXME: should not be here
var timestamp_msec: float = 0
#FIXME: hacks
var is_hold = false:
	set(v):
		if v:
			set("theme_override_styles/panel", style_hold)
			modulate = Color(1.0, 1.0, 1.0)
		is_hold = v


#hacks for hold targets
#should probably be in a subclass
var head_ref
var tail_ref:
	set(v):
		if !v:
			return
		tail_ref = v
		tail_ref.new_result.connect(_on_new_tail_result)


##

var hit_input: HitInput
var result: HitResult = HitResult.new():
	set(v):
		if v.type != HitResult.HIT_RESULT_NONE:
			_play_hit_sfx(v.type)
			_spawn_effect(v.type)

			degenerate()
			new_result.emit(v)
			result = v


var is_judged: bool = false:
	get:
		return result.type != HitResult.HIT_RESULT_NONE


@onready var hts := $HitTargetSprite
@onready var anim_player := $AnimationPlayer
@onready var stream_player := $AudioStreamPlayer


func _ready():
	if is_hold:
		set("theme_override_styles/panel", style_hold)
		modulate = Color(1.0, 1.0, 1.0)

	match hit_input.column:
		RhythmGameConstants.COLUMN.DOWN:
			hts.texture = textures["down"]
		RhythmGameConstants.COLUMN.LEFT:
			hts.texture = textures["left"]
		RhythmGameConstants.COLUMN.RIGHT:
			hts.texture = textures["right"]
		RhythmGameConstants.COLUMN.UP:
			hts.texture = textures["up"]
		_:
			printerr("Hit target has no texture set!")


func _process(delta):
	#FIXME: hack
	if tail_ref && tail_ref.is_judged:
		_stop_hit_sfx()
	if self.is_judged:
		return
	if timestamp_msec - hit_input.timestamp > HitJudge.thresholds_ms["miss"]:
		force_miss()


func degenerate():
	if anim_player && hts:
		anim_player.play("degenerate")
		hts.hide()


func _play_hit_sfx(hit_result: int):
	var stream = hit_sfxs.get(hit_result)
	if stream == null:
		return

	#FIXME: hack
	if is_hold && tail_ref:
		stream = hold_sfx

	stream_player.stream = stream
	stream_player.play()


#only used for holds
func _stop_hit_sfx():
	stream_player.stop()


func _on_new_tail_result(hit_result):
	_stop_hit_sfx()


func _spawn_effect(hit_result: int):
	var scene = effects.get(hit_result)
	if scene == null:
		return

	var effect = scene.instantiate() as Node2D
	effect.global_position = global_position + pivot_offset
	# TODO: Likely not the best place to add the effect to
	get_viewport().add_child(effect)


func check_result(hi: HitInput):
	var judgment: HitJudge = HitJudge.new()
	var res: HitResult = judgment.compare(hi, hit_input)

	if force_miss_on_input_change && res.type == res.HIT_RESULT_NONE:
		force_miss()
	else:
		self.result = res


func force_miss():
	if tail_ref:
		tail_ref.force_miss()
	self.result = HitResult.new(HitResult.HIT_RESULT_MISS)
