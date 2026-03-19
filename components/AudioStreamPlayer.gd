extends Node

@export var alias: String = ""
@export var autoplay_random_position: bool = false

@onready var tween := Threen.new()

var volume: float:
	set(value):
		var db: float = linear_to_db(clamp(value, 0, 1))
		set("volume_db", db)
	get:
		var db: float = get("volume_db")
		return clamp(db_to_linear(db), 0, 1)

var _command_handler = _run_command

func _enter_tree():
	assert(_is_player())
	if alias == "":
		alias = name
	Story.add_command_handler(_command_handler)


func _ready():
	add_child(tween)

	if autoplay_random_position:
		var pos = randf_range(0, _get_stream_length())
		call("play", pos)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _is_player() -> bool:
	return get_class() in ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D"]


func _is_playing() -> bool:
	return get("playing")


func _play(from_position: float = 0.0, delay: float = 0.0):
	if delay > 0:
		await Utils.wait(delay)

	call("play", from_position)


func _stop():
	call("stop")


func _get_stream_length() -> float:
	var stream = get("stream") as AudioStream
	return stream.get_length()


func fade_in(duration: float = 1):
	await fade(true, duration)


func fade_out(duration: float = 1):
	await fade(false, duration)


func fade(into: bool, duration: float = 1, max_volume: float = 1):
	var vol = [0 if into else self.volume, max_volume if into else 0]

	self.volume = vol[0]
	tween.interpolate_property(self, "volume", vol[0], vol[1], duration)
	tween.start()

	if into and not _is_playing():
		_play()
	await tween.tween_completed


func try_play():
	if not _is_playing():
		_play()


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	if params.size() > 0 and str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"play_sound":
			var position: float = cmd.tags.get("position", 0.0)
			var delay: float = cmd.tags.get("delay", 0.0)
			_play(position, delay)

			if flags.has("once"):
				var stream_length = _get_stream_length()
				await Utils.wait(stream_length)
				_stop()
		"stop_sound":
			_stop()
		"fade_in_sound", "fade_out_sound":
			var into = cmd.name.begins_with("fade_in")
			var duration := 1.0
			var max_volume := 1.0

			if params.size() >= 2:
				duration = params[1]

			if cmd.flags.has("keep-vol"):
				max_volume = self.volume
			if params.size() >= 3:
				max_volume = params[2]

			fade(into, duration, max_volume)
		_:
			return Constants.CMD_RETURN_NONE

	return null
