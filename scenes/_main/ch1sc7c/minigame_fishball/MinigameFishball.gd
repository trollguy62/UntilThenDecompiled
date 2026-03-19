extends Node2D

signal game_finished

@onready var anim_player = $AnimationPlayer
@onready var main_label = $MainLabel

@onready var player_mark = $PlayerMark
@onready var player_sofia = $PlayerSofia
@onready var players = [player_mark, player_sofia]

@onready var music = $Audio/Music
@onready var fanfare_victory = $Audio/FanfareVictory
@onready var fanfare_defeat = $Audio/FanfareDefeat
@onready var sfx_ready_set = $Audio/ReadySet
@onready var sfx_go = $Audio/Go
@onready var sfx_aim = $Audio/Aim
@onready var sfx_attack = $Audio/Attack
@onready var sfx_grab = $Audio/Grab
@onready var sfx_miss = $Audio/Miss

@onready var oil = $FgOil


func _ready():
	main_label.modulate = Color.TRANSPARENT
	oil.play("default")
	for player in players:
		player.aimed.connect(sfx_aim.play)
		player.attack_started.connect(sfx_attack.play)
		player.attack_worked.connect(sfx_grab.play)
		player.attack_failed.connect(sfx_miss.play)


func start():
	Game.record_replay_pause()
	get_tree().call_group("fishballs", "awake")
	music.position = 0
	music.current_track = "Mark"

	sfx_ready_set.play()
	await _set_main_text(tr("MG_FISHBALL_READY"))
	sfx_ready_set.play()
	await _set_main_text(tr("MG_FISHBALL_SET"))
	sfx_go.play()
	await _set_main_text(tr("MG_FISHBALL_GO"))

	var cur_idx = 0
	var winner = null

	while winner == null:
		var cur_player = players[cur_idx]
		cur_player.start_turn()

		if cur_player == player_mark:
			music.current_track = "Mark"
		elif cur_player == player_sofia:
			music.current_track = "Sofia"

		await cur_player.turn_finished
		if cur_player.is_winner():
			winner = cur_player
		else:
			cur_idx = (cur_idx + 1) % players.size()
			await Utils.wait(1)

	var mark_won = winner == player_mark
	var last_text = tr("MG_FISHBALL_YOU_WIN") if mark_won else tr("MG_FISHBALL_YOU_LOSE")
	music.current_track = ""

	if mark_won:
		fanfare_victory.play()
	else:
		fanfare_defeat.play()

	await _set_main_text(last_text, 3, false)
	game_finished.emit()
	Game.record_replay_resume()


func _set_main_text(string: String, show_dur: float = 1, hide_after: bool = true):
	main_label.text = "[center][wave]%s[/wave][/center]" % string
	anim_player.play("show_main_label")

	await anim_player.animation_finished
	await Utils.wait(show_dur)

	if hide_after:
		anim_player.play("hide_main_label")
		await anim_player.animation_finished
