extends Node

const StreamLooper = preload("res://components/StreamLooper.gd")

var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func play_persist(stream: AudioStream, volume_db: float = 0, bus: String = "Music"):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db

	add_child(player)
	player.play()
	player.finished.connect(_stop_persist.bind(player))


func _stop_persist(player: AudioStreamPlayer):
	remove_child(player)
	player.queue_free()


func stop_all_persists():
	for player in get_children():
		remove_child(player)
		player.queue_free()


func stop_all_players(node: Node):
	var players = []
	Utils.search_descendants(node, is_player, players)

	for player in players:
		player.stop()
		if player is StreamLooper:
			player.enabled = false


func is_player(node: Node) -> bool:
	return node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D


func set_volume_db(node: Node, db: float):
	if is_player(node):
		node.volume_db = db


func get_volume_db(node: Node) -> float:
	if is_player(node):
		return node.volume_db
	else:
		return 0.0


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"play_sound_persist":
			var stream_path = params[0]
			var stream = load(stream_path)
			var volume_db: float = 0
			var bus = "Music"

			if params.size() >= 2:
				volume_db = linear_to_db(clamp(params[1], 0, 1))

			if params.size() >= 3:
				bus = params[2]

			play_persist(stream, volume_db, bus)
		_:
			return Constants.CMD_RETURN_NONE

	return null
