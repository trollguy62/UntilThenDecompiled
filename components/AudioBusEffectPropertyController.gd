extends Node

@export var audio_bus_name: String
@export var audio_effect_name: String
@export var property: String
@export var enabled := true:
	set(v):
		enabled = v
		if _bus_idx >= 0 and _effect_idx >= 0:
			AudioServer.set_bus_effect_enabled(_bus_idx, _effect_idx, enabled)
	get:
		return AudioServer.is_bus_effect_enabled(_bus_idx, _effect_idx)
@export var value := 0.0:
	set(v):
		value = v
		if _effect:
			_effect.set(property, value)
	get:
		return _effect.get(property)
@export var apply_on_ready := false

var _bus_idx: int = -1
var _effect_idx: int = -1
var _effect: AudioEffect


func _ready():
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == audio_bus_name:
			_bus_idx = i
			break

	assert(_bus_idx >= 0)

	for i in range(AudioServer.get_bus_effect_count(_bus_idx)):
		var effect = AudioServer.get_bus_effect(_bus_idx, i)

		if Utils.get_custom_class_of(effect) == "AudioEffect%s" % audio_effect_name:
			_effect_idx = i
			_effect = effect
			break

	assert(_effect_idx >= 0)
	assert(_effect != null)

	if apply_on_ready:
		self.enabled = enabled
		self.value = value
