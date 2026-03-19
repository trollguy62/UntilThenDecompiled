extends SkitContainer


@onready var ca_start_cathy = $Misc/CaStartCathy


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(name: String, value):
	match name:
		"disable_ca_start_cathy":
			ca_start_cathy.enabled = false
