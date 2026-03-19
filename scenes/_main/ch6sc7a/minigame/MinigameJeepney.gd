extends Node2D

signal beat
signal game_finished

const MAX_EARLY_INPUT_TOLERANCE = -0.1 #of a beat
const MAX_LATE_INPUT_TOLERANCE = 0.1 #of a beat
const PRE_INPUT_BEAT_COUNT = 4
const Barya = preload("res://scenes/_main/ch6sc7a/minigame/Barya.tscn")

var _total_beats = 0
var _track: Dictionary = {}
var _barya_stack = []
var _last_beat: float = 0
var _lead_in: float = 0

var success_count = 0
var fail_count = 0
###
# audioFile ## file must exist
# audioLeadin ## in seconds
# _track.bpm
# events
###

@onready var music = $Music
@onready var npc_s = $NPC/Sprite
@onready var npc_animplayer = $NPC/AnimationPlayer
@onready var cathy_s = $Cathy/Sprite
@onready var mark_s = $Mark/Sprite
@onready var driver = $Driver
@onready var driver_head_s = $Driver/Head/Sprite
@onready var driver_hand_s = $Driver/Hand/Sprite
@onready var boombox = $Environment/BoomBox
@onready var trash_can = $TrashCan

@onready var syncer = $Syncer

func _ready():
	beat.connect(_on_beat_hit)
	music.finished.connect(_on_music_finished)
	npc_s.frame_changed.connect(_on_frame_changed)
	load_track("res://scenes/_main/ch6sc7a/minigame/assets/tracks/track1.json")
	#start()


func _process(delta):
	var seconds_per_beat = 60.0 / _track.bpm
	var offset = Game.config.rhythm_offset_ms / 1000.0
	var timestamp = music.get_playback_position() + AudioServer.get_output_latency() - offset

	for barya in _barya_stack:
		if is_instance_valid(barya):
			barya.timestamp = timestamp

	if timestamp - _last_beat >= seconds_per_beat:
		_total_beats += 1
		_last_beat = seconds_per_beat * _total_beats
		beat.emit(_total_beats)


func start():
	music.play()
	cathy_s.play()
	mark_s.play()
	npc_s.play()
	driver_hand_s.play()
	driver_head_s.play()
	_total_beats = 0
	##
	music.play()
	##


func load_track(path):
	_track = Utils.read_json_file(path)
	music.stream = load(_track.audioFile)
	_track.bpm = float(_track.bpm)
	_track.audioLeadIn = float(_track.audioLeadIn)
	for i in _track["events"].size():
		_track["events"][i] = int(_track["events"][i])


func _unhandled_input(event):
	if (
		music.playing
		and (event.is_action_pressed("c_interact") or event.is_action_pressed("interact"))
	):
		mark_s.beat()


func _check_input():
	if false:
		_on_successful_input()
	if false:
		_on_failed_input()


func update_debug_elements():
	$Control/Measure.text = "Measure: " + str(int(_total_beats / 4))
	$Control/Beat.text = "Beat: " + str(_total_beats % 4 + 1)


func _on_beat_hit(total_beats: int):
	var beat_in_measure = total_beats % 4 + 1

	if total_beats >  _track["events"].back():
		mark_s.animation_looped.connect(func(): mark_s.animation = "idle_happy", CONNECT_ONE_SHOT)


	#count 2 beats ahead to account for the npc grabbing the coin
	if total_beats + 2 in _track["events"]:
		_start_sequence()

	#for environment pieces
	match beat_in_measure:
		1:
			boombox.beat()
		2:
			#boombox.beat()
			pass
		3:
			boombox.beat()
		4:
			#boombox.beat()
			pass
		_:
			printerr("invalid beat number")
			pass


func _start_sequence():
	var barya = Barya.instantiate()

	barya.min_input_threshold = (_total_beats + PRE_INPUT_BEAT_COUNT + MAX_EARLY_INPUT_TOLERANCE) * 60.0 / _track.bpm
	barya.max_input_threshold = (_total_beats + PRE_INPUT_BEAT_COUNT + MAX_LATE_INPUT_TOLERANCE) * 60.0 / _track.bpm
	barya.queued_for_deletion.connect(func(): _barya_stack.erase(barya))

	$NPC/CoinTarget.add_child(barya)
	barya.visible = false

	#$NPC/AnimationPlayer.play("CoinTargetUpdates")
	_barya_stack.append(barya)
	npc_s.animation = "grab"
	#barya.pass_from_offscreen()
	#0
	await beat
	#1 throw
	await beat
	npc_s.set_state("toss")
	npc_s.beat()
	cathy_s.set_state("pretoss")
	barya.throw_1()
	#2 cathy
	await beat
	barya.throw_2()
	barya.success.connect(_on_successful_input, CONNECT_ONE_SHOT)
	barya.failure.connect(_on_failed_input, CONNECT_ONE_SHOT)
	cathy_s.set_expr("yehey")
	cathy_s.set_state("toss")
	cathy_s.beat()
	mark_s.set_state("pretoss")
	#3 mark (player)
	await beat
	###player input here
	#mark_s.animation = "toss_yehey"
	driver_head_s.animation = "happy"
	driver_hand_s.animation = "grab"
	#4 driver
	await beat
	#barya.success.emit()
	###driver feedback here


func _on_failed_input():
	mark_s.set_expr("sad", 3)
	mark_s.animation_looped.connect(mark_s.set_expr.bind("happy", 3), CONNECT_ONE_SHOT)
	cathy_s.set_expr("sad", 3)
	driver_head_s.animation = "sad"
	trash_can.rattle()
	fail_count += 1


func _on_successful_input():
	mark_s.animation = "toss_yehey"
	driver_head_s.animation = "happy"
	driver_hand_s.animation = "grab"
	success_count += 1


func _on_music_finished():
	await get_tree().create_timer(5.0).timeout
	set_achievement()
	emit_signal("game_finished")

func set_achievement():
	if fail_count == 0:
		Game.dist_platform.unlock_achievement("ACH_JEEP_100")

	if success_count == 0:
		Game.dist_platform.unlock_achievement("ACH_JEEP_0")


func _on_frame_changed():
	if npc_s.frame == 3:
		if not _barya_stack.is_empty():
			var barya = _barya_stack.back()
			if barya != null:
				barya.visible = true
