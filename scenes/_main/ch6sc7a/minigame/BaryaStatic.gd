extends Node2D

signal success
signal failure

const MAX_INPUT_TOLERANCE = 0.2
const EARLY_INPUT_THRESHOLD = -0.4

@onready var spr = $Sprite
@onready var base_path = $Node/PathBase/PathFollow2D
@onready var result_path = $Node/PathResult/PathFollow2D
@onready var npc_path = $Node/PathNPC/PathFollow2D
@onready var anim_player = $AnimationPlayer
@onready var input_timer = $InputTImer
@onready var remote_transforms = {}

var _t = 0
var _enable_input_window_queued = false
var _handled = false


func _ready():
	#input_timer.timeout.connect(_on_input_timer_timeout)
	remote_transforms["base"] = $Node/PathBase/PathFollow2D/RemoteTransform2D
	remote_transforms["result"] = $Node/PathResult/PathFollow2D/RemoteTransform2D
	#remote_transforms["npc"] = $Node/PathNPC/PathFollow2D/RemoteTransform2D
	failure.connect(throw_3.bind(false), CONNECT_ONE_SHOT)
	success.connect(throw_3.bind(true), CONNECT_ONE_SHOT)


#FIXME: hack
func _on_input_timer_timeout():
	emit_signal("failure")


func enable_input_window(bpm, drift):
	#input_timer.start(60 / bpm + drift + MAX_INPUT_TOLERANCE)
	pass


func pass_from_offscreen():
#	#set_active_path("npc")
#	spr.animation = "static"
#	anim_player.play("Pass_offscreen")
	pass


func throw_1():
#	set_active_path("base")
#	spr.animation = "default"
#	anim_player.play("Pass_1")
	pass


func throw_2():
#	set_active_path("base")
#	spr.animation = "default"
#	anim_player.play("Pass_2")
	pass


func throw_3(passed: bool):
#	set_active_path("result")
#	if passed:
#		anim_player.play("Pass_3")
#	else:
#		anim_player.play("Pass_Fail")
#
##	#FIXME: Hack
#	await anim_player.animation_finished
#	queue_free()
#	##
	pass

func set_active_path(which):
#	for k in remote_transforms.keys():
#		remote_transforms[k].update_position = k == which
	pass


func check_input():
#	if (
#		input_timer.is_stopped()
#		or input_timer.time_left >= MAX_INPUT_TOLERANCE - EARLY_INPUT_THRESHOLD
#		or _handled
#	):
#		return
#	if (
#		input_timer.time_left > 2 * MAX_INPUT_TOLERANCE
#		and input_timer.time_left < MAX_INPUT_TOLERANCE - EARLY_INPUT_THRESHOLD
#	):
#		emit_signal("failure")
#		_handled = true
#		return
#	if abs(input_timer.time_left - MAX_INPUT_TOLERANCE) < MAX_INPUT_TOLERANCE:
#		input_timer.stop()
#		emit_signal("success")
#	else:
#		input_timer.stop()
#		emit_signal("failure")
#
#	_handled = true
	pass


func _on_animation_finished(anim_name: String):
#	if anim_name == "Pass_3" or anim_name == "Pass_Fail":
#		#FIXME: hack
#		#await get_tree().create_timer(0.2)
#		#
#		queue_free()
	pass

func _unhandled_input(event):
	if (
		event.is_action_pressed("c_interact")
		or event.is_action_pressed("interact") and not _handled
	):
		check_input()
