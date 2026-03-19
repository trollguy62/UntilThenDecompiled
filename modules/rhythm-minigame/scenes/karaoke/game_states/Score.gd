extends "../../../classes/state_machine/KState.gd"

@export var entry_playback_pos: float = 2.0  #in seconds, playback position of celebratory_sfx stream when we stop rolling
@export var message_playback_pos: float = 4.0
@export var celebratory_sfx: AudioStream
@export var score_linger_time: float = 6.0  #seconds

@export var pts_per_perfect: float = 1.0
@export var pts_per_great: float = 0.7
@export var pts_per_miss: float = 0.0


func on_entered():
	target.logo.hide()
	target.scoring.show()
	target.karaoke_buttons.is_enabled = false
	target.karaoke_buttons.is_voice_enabled = false
	target.is_soundboard_enabled = false
	assert(celebratory_sfx)
	target.audio_player.stream = celebratory_sfx
	target.audio_player.play()

	var numeric_score = _calculate_score()

	target.last_score = numeric_score
	target.last_completed_song_id = target.current_song_id
	target.current_song_id = -1

	target.score_screen.numeric_score = numeric_score
	target.score_screen.message_delay = message_playback_pos
	target.score_screen.animate_roll(10, 99, entry_playback_pos)
	target.score_screen.celebratory_sfx_ended.connect(_on_celebratory_sfx_ended, CONNECT_ONE_SHOT)

	set_achievement(numeric_score)


func on_exited():
	target.scoring.hide()
	target.logo.show()


func _on_celebratory_sfx_ended():
	await get_tree().create_timer(score_linger_time).timeout

	if target.song_queue.is_empty():
		ksm.transition_to(ksm.states["Idle"])
	else:
		ksm.transition_to(ksm.states["Sing"])


func _calculate_score() -> int:
	var hit_target_count: int = 0
	for key in target.score.keys():
		hit_target_count += target.score[key]

	var perfect_subtotal = pts_per_perfect * target.score["perfect"]
	var great_subtotal = pts_per_great * target.score["great"]
	var miss_subtotal = pts_per_miss * target.score["miss"]
	var numeric_score: int
	if hit_target_count == 0:
		numeric_score = 0
	else:
		numeric_score = (
			(perfect_subtotal + great_subtotal + miss_subtotal)
			/ float(hit_target_count)
			* 100
		)

	numeric_score = clamp(numeric_score, 0, 100)

	return numeric_score

func set_achievement(score):
	if score >= 100:
		Game.dist_platform.unlock_achievement("ACH_VIDEOKE_100")
	elif score >= 85 and score <= 99:
		Game.dist_platform.unlock_achievement("ACH_VIDEOKE_85_99")
