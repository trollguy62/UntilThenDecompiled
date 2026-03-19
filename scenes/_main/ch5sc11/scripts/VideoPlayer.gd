extends VideoStreamPlayer

var skit_container: SkitContainer


func _ready():
	# WebM stream doesn't like being paused by the engine time scale
	paused = true
	autoplay = false


func _skit_start(skit_container: SkitContainer):
	self.skit_container = skit_container


func _process(_delta):
	if stream == null:
		return
	if is_instance_valid(skit_container) and skit_container.is_running and not is_playing():
		paused = false
		play()
