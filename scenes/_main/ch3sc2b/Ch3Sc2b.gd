extends Scene

@onready var audio_event_ferris_wheel = $Audio/SFX/Envi/FerrisWheel


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(s: String, value):
	match s:
		"ferris_wheel_turn":
			var duration = float(value)
			audio_event_ferris_wheel.set_parameter("ferris_wheel_speed", 1.0)
			await Utils.wait(duration)
			audio_event_ferris_wheel.set_parameter("ferris_wheel_speed", 0.0)
