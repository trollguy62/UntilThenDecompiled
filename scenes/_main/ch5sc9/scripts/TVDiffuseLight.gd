@tool
extends OmniLight3D

@export var speed := 1.0
@export var base_color := Color.WHITE
@export var h_random := 0.0
@export var s_random := 0.0
@export var v_low := 0.8
@export var v_high := 1.0

var _noise_h := FastNoiseLite.new()
var _noise_s := FastNoiseLite.new()
var _noise_v := FastNoiseLite.new()

var _t := 0.0


func _ready():
	Utils.randomize()
	_noise_h.seed = randi()
	_noise_s.seed = randi()
	_noise_v.seed = randi()


func _process(delta):
	_t += delta
	var t = _t * speed

	var color = base_color
	color.h = fmod(color.h + h_random * _noise_h.get_noise_1d(t + 0.11), 1.0)
	color.s = fmod(color.s + s_random * _noise_s.get_noise_1d(t + 0.23), 1.0)

	var v = lerp(v_low, v_high, _noise_v.get_noise_1d(t))
	light_color = color * v
