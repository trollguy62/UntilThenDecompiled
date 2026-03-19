extends Node
class_name AudioCrossFade

@export var from: NodePath
@export var to: NodePath
@export_range(0.01, 128) var duration: float = 1.0
@export var oneshot := true
@export var sync_position := false

@onready var tween := Threen.new()
var _fired := false


func _ready():
	add_child(tween)


func cross_fade():
	if oneshot and _fired:
		return
	if not _fired:
		_fired = true

	var audio_from = get_node(from)
	var audio_to = get_node(to)
	if not _is_player(audio_from) or not _is_player(audio_to):
		return

	if not audio_from.is_playing():
		audio_from.play()
	if not audio_to.is_playing():
		audio_to.play()

	if sync_position:
		var pos = min(audio_from.get_playback_position(), audio_to.stream.get_length())
		audio_to.seek(pos)

	var track_from = Track.new(audio_from)
	var track_to = Track.new(audio_to)
	_fade(false, track_from)
	_fade(true, track_to)

	tween.start()
	await tween.tween_completed
	audio_from.stop()


func _is_player(node: Node):
	return node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D


func _fade(into: bool, track: Track):
	var vol = [0, track.volume]
	if not into:
		vol.reverse()
	tween.interpolate_property(track, "volume", vol[0], vol[1], duration)


class Track:
	var player: Node
	var volume: float:
		set(value):
			player[_db_prop] = linear_to_db(value)
		get:
			return db_to_linear(player[_db_prop])
	var _db_prop: String

	func _init(player: Node):
		self.player = player
		_db_prop = "unit_db" if player is AudioStreamPlayer3D else "volume_db"
