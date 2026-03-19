extends CanvasLayer



func _skit_start(skit: SkitContainer):
	_play()

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	var preop = $PreOpeningModded
	preop.fallen.connect(Story.emit.bind("fallen"))
	preop.rain.connect(Story.emit.bind("rain"))
	preop.cue_butterfly.connect(Story.emit.bind("cue_butterfly"))
	preop.cue_end.connect(Story.emit.bind("cue_end"))

func _play():
	visible = true
	$PreOpeningModded._play()
