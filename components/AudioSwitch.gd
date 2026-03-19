extends Node

@export var alias = ""
@export var current_track = "":
	set(value):
		current_track = value
		if tween:
			_cross_fade_to(current_track, cross_fade_duration)

@export var position: float = 0.0:
	set(value):
		position = value
		if tween:
			for track in tracks.values():
				track.player.play(position)

@export_range(0.01, 16) var cross_fade_duration: float = 0.5
@export_range(0, 1) var volume_mult: float = 1.0:
	set(value):
		volume_mult = value
		if tween:
			self.current_track = current_track

@onready var tween = Threen.new()

var tracks := {}
var _command_handler = _run_command


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _ready():
	if alias == "":
		alias = name

	for player in get_children():
		if not AudioUtils.is_player(player):
			continue

		var track = Track.new(player)
		track.volume = 0
		tracks[player.name] = track
		player.play(position)

	add_child(tween)
	self.volume_mult = volume_mult


func _cross_fade_to(track_name: String, cross_fade_duration: float):
	tween.stop_all()

	for id in tracks.keys():
		var track: Track = tracks[id]
		var target_volume: float = 1 if id == track_name else 0
		target_volume *= volume_mult
		tween.interpolate_property(
			track, "volume", track.volume, target_volume, cross_fade_duration
		)

	tween.start()


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	if params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"switch_sound":
			var track_name: String = params[1]
			var play_from_pos := -1.0
			var no_cross_fade = flags.has("no-cross-fade")
			var cross_fade_duration = tags.get("cross_fade_duration", self.cross_fade_duration)

			if params.size() >= 3:
				play_from_pos = float(params[2])

			if play_from_pos >= 0:
				self.position = play_from_pos

			current_track = track_name
			_cross_fade_to(current_track, 0 if no_cross_fade else cross_fade_duration)
		_:
			return Constants.CMD_RETURN_NONE

	return null


class Track:
	var player

	@export var volume: float:
		set(value):
			var db = linear_to_db(clamp(value, 0, 1))
			AudioUtils.set_volume_db(player, db)
		get:
			var db = AudioUtils.get_volume_db(player)
			return clamp(db_to_linear(db), 0, 1)

	func _init(player):
		self.player = player
