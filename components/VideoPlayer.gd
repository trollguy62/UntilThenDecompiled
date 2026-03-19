extends VideoStreamPlayer

@export var videos := {}  # Map<String, VideoStream>


func _ready():
	finished.connect(_on_video_finished)

	for k in videos.keys():
		assert(typeof(k) == TYPE_STRING)
		assert(videos[k] is VideoStream)


func _process(delta):
	visible = is_playing()


func play_video_with_key(key: String) -> bool:
	if not key in videos:
		return false

	self.stream = videos[key]
	play()

	return true


func _on_video_finished():
	self.stream = null
	stop()


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"play_video":
			var key = str(params[0])
			var no_wait = flags.has("no-wait")

			if play_video_with_key(key):
				if not no_wait:
					await finished

				return true

	return Constants.CMD_RETURN_NONE
