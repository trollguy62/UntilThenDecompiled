extends "res://scenes/_main/ch1sc8/scripts/RainControllable.gd"

@onready var audio_event_emitter: Node = get_parent()


func _ready():
	assert(audio_event_emitter is StudioEventEmitter2D or audio_event_emitter is StudioEventEmitter3D)
	self.intensity = intensity


func _set_intensity(value):
	intensity = value

	if is_inside_tree():
		await get_tree().process_frame
		audio_event_emitter.set_parameter("Intensity", value)
