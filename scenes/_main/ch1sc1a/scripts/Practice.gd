extends SkitContainer


func _ready():
	super._ready()
	emitted.connect(_on_skit_emitted)


func _on_skit_emitted(name: String, value):
	match name:
		"cross_fade_mid1_mid2":
			$Audio/ACF_Mid1_Mid2.cross_fade()
		"show_controls":
			$Root2D/Controls._start()
