extends "../../../classes/state_machine/KState.gd"

#there's an implicit target var that has the object we want to modify
#* No active song
#* Waiting for one song to be queued, after which we transition to Sing state
#* Player can enter a song number
#* Mic Ko logo is visible at all times
#* If pending song:
#*  * Song number input is shown above song title and, optionally, artist (because Auld Lang Syne might have no artist)
#* If song number is not registered (which obviously cannot be entered), show `tr("MG_KARAOKE_NO_SONG")`

const KaraokeSong = preload("../KaraokeSong.gd")

var pending_song: int = 0


func on_entered():
	target.led.reset()

	target.popular_songs.show()
	target.idle.show()

	target.song_info.hide()

	target.karaoke_buttons.is_enabled = true
	target.karaoke_buttons.is_voice_enabled = true
	target.is_soundboard_enabled = true

	target.led.idle_wait_time = target.input_timer.wait_time  #sec
	target.input_timer.timeout.connect(_on_input_timer_timeout)
	target.selection_timer.timeout.connect(_on_selection_timer_timeout)
	target.extra_buttons["Play"].pressed.connect(_on_play_pressed)
	target.pending_song_changed.connect(_on_pending_song_changed)

	target.input_timer.start()


func on_exited():
	target.idle.hide()
	target.input_timer.timeout.disconnect(_on_input_timer_timeout)
	target.selection_timer.timeout.disconnect(_on_selection_timer_timeout)
	target.extra_buttons["Play"].pressed.disconnect(_on_play_pressed)
	target.pending_song_changed.disconnect(_on_pending_song_changed)


func _on_input_timer_timeout():
	target.song_info.reset()
	target.song_info.hide()
	target.popular_songs.show()
	target.led.reset()


func _on_selection_timer_timeout():
	target.led.reset()
	target.song_queue.queue(target.song_db[pending_song])
	ksm.transition_to(ksm.states["Sing"])


func _on_pending_song_changed(id: int):
	target.input_timer.start()
	target.selection_timer.stop()
	target.popular_songs.hide()
	target.song_info.show()

	pending_song = id

	var s = KaraokeSong.new(tr("MG_KARAOKE_NO_SONG"), "", pending_song)

	if pending_song in target.song_db:
		target.selection_timer.start()
		s = target.song_db[pending_song]

	target.song_info.set_song(s)


func _on_play_pressed():
	var s = KaraokeSong.new(tr("MG_KARAOKE_NO_SONG"), "", pending_song)
	if pending_song in target.song_db:
		s = target.song_db[pending_song]
		target.song_queue.queue(target.song_db[pending_song])
		pending_song = 0
		target.led.reset()
		target.led.is_idle = true
		target.selection_timer.stop()
		ksm.transition_to(ksm.states["Sing"])
