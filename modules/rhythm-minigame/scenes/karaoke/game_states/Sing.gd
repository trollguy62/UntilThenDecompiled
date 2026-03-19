extends "../../../classes/state_machine/KState.gd"

#there's an implicit target var that has the object we want to modify
#* Fake loading by about 1-2 seconds before the song starts playing and Sing state UI appears
#* Player can enter a song number
#* Initial screen appears until a few seconds before the first lyric
#* Show queued song numbers next to Mic Ko logo
#* If pending song:
#* Mic Ko logo is hidden, swapped with song number input UI as shown
#* Queued songs are hidden
#* If not pending song:
#* Mic Ko logo is visible (including in the initial screen shown above)
#* Lyrics behavior:
#* Line-per-line linear speed determined by its duration and text length (i.e., if line has duration of 2 seconds, half its length should have turned blue by 1 second)
#* Lyrics should appear well before it actually starts, so the player can anticipate upcoming HitObjects

const KaraokeSong = preload("../KaraokeSong.gd")
const KaraokeHitTarget = preload("../KaraokeHitTarget.gd")
const OsuBeatmap = preload("../../../classes/beatmap/OsuBeatmap.gd")
const OsuParser = preload("../../../classes/parser/OsuParser.gd")
const OsuHitObject = preload("../../../classes/beatmap/OsuHitObject.gd")
const LrcParser = preload("../../../classes/parser/LrcParser.gd")
const LrcObject = preload("../../../classes/lrc/LrcObject.gd")
const HitInput = preload("../../../classes/input/HitInput.gd")

@export var song_lead_in: float = 3000.0  #ms
@export var lyric_lead_in: float = 3000.0  #ms
@export_range(0, 1, 0.01) var force_next_line_progress: float = 0.5
@export var kht_scene: PackedScene

var pending_song: int = 0
var fake_loading_time: float = 2.0
var current_song: KaraokeSong

var _initial_playback_delay_ms: float = 0
var beatmap: OsuBeatmap
var lrc: LrcObject
var playing = false
var hit_objects: Array
var index: int = 0
var audio_latency: float
var _pending_hit_targets = []


func on_entered():
	current_song = target.song_queue.dequeue()
	assert(current_song)
	#load beatmap here maybe
	#load lrc too
	var osu_parser = OsuParser.new()
	var lrc_parser = LrcParser.new()
	beatmap = osu_parser.parse_osu_from_path(current_song.map_file_path)
	lrc = lrc_parser.parse_lrc_from_path(current_song.lrc_file_path)

	var audio_path = current_song.map_file_path.get_base_dir() + "/" + beatmap.AudioFilename
	target.audio_player.stream = _load_audio_stream(audio_path)

	await get_tree().create_timer(fake_loading_time).timeout

	target.sing.show()
	target.karaoke_buttons.is_enabled = true
	target.karaoke_buttons.is_voice_enabled = false
	target.is_soundboard_enabled = true
	target.rhythm_anchor.reset_visibility()
	target.led.idle_wait_time = 3.0

	target.input_timer.timeout.connect(_on_input_timer_timeout)
	target.selection_timer.timeout.connect(_on_selection_timer_timeout)
	target.audio_player.finished.connect(_on_audio_player_finished)
	target.extra_buttons["Stop"].pressed.connect(_on_stop_pressed)
	target.extra_buttons["Play"].pressed.connect(_on_play_pressed)
	target.pending_song_changed.connect(_on_pending_song_changed)

	target.current_song_id = current_song.id
	target.sing_initial_screen.current_song = current_song
	target.sing_initial_screen.show()
	target.led.set_value(current_song.id)

	_start()


func _load_audio_stream(path):
	var stream = null

	if ResourceLoader.exists(path):
		return load(path)
	else:
		if path.ends_with(".ogg"):
			stream = AudioStreamOggVorbis.new()
		elif path.ends_with(".mp3"):
			stream = AudioStreamMP3.new()
		else:
			assert(false)

		var file = FileAccess.open(path, FileAccess.READ)
		stream.data = file.get_buffer(file.get_len())

	if stream == null:
		push_warning("Failed to load audio stream at " + path)

	return stream


func update(delta):
	if !playing:
		return

	target.timestamp_msec = target.audio_player.get_playback_position() * 1000.0 + Game.config.rhythm_offset_ms

	if index < lrc.scripts.size():
		if (
			(index == 0 && target.timestamp_msec + lyric_lead_in >= lrc.scripts[index].time_start * 1000.0)
			|| _should_force_next_line()
		):
			#FIXME: hack
			target.sing_initial_screen.hide()
			target.rhythm_anchor.show()
			#
			var c = lrc.scripts[index]

			target.rhythm_anchor.clear_current()
			target.rhythm_anchor.lrc_script = c
			var dist = target.rhythm_anchor.get_current_size().x

			if _pending_hit_targets.size() > 0:
				var ts = _pending_hit_targets.front().hit_input.timestamp

				if _is_inside_range(ts, c.time_start * 1000.0, c.time_end * 1000.0):
					#printerr("hit_target disjointed")
					var tail = _pending_hit_targets.pop_front()
					#FIXME: hack
					tail.force_miss_on_input_change = false
					#
					tail.position.x = remap(
						tail.hit_input.timestamp,
						c.time_start * 1000.0,
						c.time_end * 1000.0,
						0,
						dist
					)
					var hold = tail.hold_line_scene.instantiate()
					#FIXME: 12.0px is half the sprite size
					hold.size.x = tail.position.x + 12.0

					target.rhythm_anchor.spawn(tail)
					target.rhythm_anchor.spawn_hold(hold)

			while hit_objects.size() > 0 && hit_objects.front().time < c.time_start * 1000.0:
				printerr("hitobject outside valid segment")
				hit_objects.pop_front()

			while (
				hit_objects.size() > 0
				&& c.time_end * 1000.0 >= hit_objects.front().time
				&& c.time_start * 1000.0 <= hit_objects.front().time
			):
				var ho: OsuHitObject = hit_objects.pop_front()
				var tail: KaraokeHitTarget
				var kht = kht_scene.instantiate()
				kht.hit_input = HitInput.new(ho.time, ho.column, true)
				kht.position.x = remap(
					ho.time, c.time_start * 1000.0, c.time_end * 1000.0, 0, dist
				)

				assert(kht.position.x >= 0)
				target.rhythm_anchor.spawn(kht)

				if ho.type & (1 << OsuHitObject.TYPE_HOLD) != 0:
					tail = kht_scene.instantiate()
					#FIXME: haaaaaaacks
					kht.tail_ref = tail
					kht.is_hold = true
					tail.head_ref = kht
					tail.is_hold = true
					var hold = kht.hold_line_scene.instantiate()
					#
					tail.force_miss_on_input_change = true
					var end_time = int(ho.objectParams.split(":", true, 1)[0])
					tail.hit_input = HitInput.new(end_time, ho.column, false)

					if end_time > c.time_end * 1000.0:
						_pending_hit_targets.append(tail)
						#disjointed
						hold.size.x = (
							target.rhythm_anchor.get_current_size().x
							- kht.position.x
						)

					else:
						tail.position.x = remap(
							end_time, c.time_start * 1000.0, c.time_end * 1000.0, 0, dist
						)

						hold.size.x = tail.position.x - kht.position.x
						#FIXME: 12.0 px = size of kht sprite
						target.rhythm_anchor.spawn(tail)

					hold.position.x = kht.position.x + 12.0
					target.rhythm_anchor.spawn_hold(hold)

			target.rhythm_anchor.move_to_next_line()
			index += 1


func on_exited():
	_stop()
	target.sing.hide()
	target.rhythm_anchor.clear_all()
	target.rhythm_anchor.reset()
	target.input_timer.timeout.disconnect(_on_input_timer_timeout)
	target.selection_timer.timeout.disconnect(_on_selection_timer_timeout)
	target.audio_player.finished.disconnect(_on_audio_player_finished)
	target.extra_buttons["Stop"].pressed.disconnect(_on_stop_pressed)
	target.extra_buttons["Play"].pressed.disconnect(_on_play_pressed)
	target.pending_song_changed.disconnect(_on_pending_song_changed)


func _should_force_next_line():
	return (
		target.rhythm_anchor.lines_left <= 1
		&& target.rhythm_anchor.query_progress() >= force_next_line_progress
	)


func _is_inside_range(value, min_value, max_value):
	return value >= min_value && value <= max_value


func _start():
	audio_latency = target.get_audio_latency_msec()
	playing = true
	_initial_playback_delay_ms = audio_latency - song_lead_in
	target.initial_playback_delay_timer.start(_initial_playback_delay_ms)
	target.initial_playback_delay_timer.timeout.connect(target.audio_player.play, CONNECT_ONE_SHOT)
	index = 0
	hit_objects = beatmap.HitObjects.duplicate()
	_reset_score()


func _reset_score():
	for key in target.score.keys():
		target.score[key] = 0


func _stop():
	playing = false
	target.audio_player.stop()
	_initial_playback_delay_ms = 0
	index = 0
	_pending_hit_targets.clear()


func _on_input_timer_timeout():
	_reset_ui()
	target.input_timer.stop()


func _on_selection_timer_timeout():
	_reset_ui()
	target.song_queue.queue(target.song_db[pending_song])
	pending_song = 0
	target.led.is_idle = true


func _reset_ui():
	target.top_bar_input.reset()
	target.top_bar_input.hide()
	target.logo.show()
	target.led.set_value(current_song.id)
	target.song_queue.show()


func _on_audio_player_finished():
	target.audio_player.playing = false
	ksm.transition_to(ksm.states["Scoring"])


func _on_pending_song_changed(id: int):
	target.top_bar_input.show()
	target.input_timer.start()

	target.selection_timer.stop()
	target.logo.hide()
	target.song_queue.hide()

	pending_song = id

	var s = KaraokeSong.new(tr("MG_KARAOKE_NO_SONG"), "", pending_song)
	if pending_song in target.song_db:
		target.selection_timer.start()
		s = target.song_db[pending_song]

	target.top_bar_input.song = s


func _on_stop_pressed():
	if target.song_queue.is_empty():
		ksm.transition_to(ksm.states["Idle"])
	else:
		ksm.transition_to(ksm.states["Sing"])


func _on_play_pressed():
	var s = KaraokeSong.new(tr("MG_KARAOKE_NO_SONG"), "", pending_song)
	if pending_song in target.song_db:
		s = target.song_db[pending_song]
		target.song_queue.queue(target.song_db[pending_song])
		pending_song = 0
		target.led.is_idle = true
		target.selection_timer.stop()

	_reset_ui()
