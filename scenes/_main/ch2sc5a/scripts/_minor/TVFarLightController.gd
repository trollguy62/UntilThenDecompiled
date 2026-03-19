@tool
extends SpotLight3D

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


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var tags = cmd.tags

	match cmd.name:
		"set_tv_far_light_props":
			for prop in ["speed", "base_color", "h_random", "s_random", "v_low", "v_high"]:
				var value = tags.get(prop, self[prop])
				if prop == "base_color":
					value = Color(value)
				self[prop] = value
		_:
			return Constants.CMD_RETURN_NONE

	return null
