extends Node2D

signal queued_for_deletion
signal success
signal failure

const MAX_INPUT_TOLERANCE = 0.05
const EARLY_INPUT_THRESHOLD = -0.4

@onready var spr = $Sprite
@onready var base_path = $Node/PathBase/PathFollow2D
@onready var result_path = $Node/PathResult/PathFollow2D
#@onready var npc_path = $Node/PathNPC/PathFollow2D
@onready var anim_player = $AnimationPlayer
@onready var input_timer = $InputTImer
@onready var remote_transforms = {}

var min_input_threshold: float = 0.0
var max_input_threshold: float = 0.0
var timestamp: float = 0.0 #in s

var _t = 0
var _enable_input_window_queued = false
var _handled = false


func _ready():
	input_timer.timeout.connect(_on_input_timer_timeout)
	remote_transforms["base"] = $Node/PathBase/PathFollow2D/RemoteTransform2D
	remote_transforms["result"] = $Node/PathResult/PathFollow2D/RemoteTransform2D
	#remote_transforms["npc"] = $Node/PathNPC/PathFollow2D/RemoteTransform2D
	failure.connect(throw_3.bind(false), CONNECT_ONE_SHOT)
	success.connect(throw_3.bind(true), CONNECT_ONE_SHOT)


#FIXME: hack
func _on_input_timer_timeout():
	#emit_signal("failure")
	pass


func enable_input_window(bpm, drift):
	input_timer.start(60 / bpm + drift + MAX_INPUT_TOLERANCE)


func pass_from_offscreen():
	#set_active_path("npc")
	spr.animation = "static"
	anim_player.play("Pass_offscreen")


func throw_1():
	set_active_path("base")
	spr.animation = "default"
	anim_player.play("Pass_1")


func throw_2():
	set_active_path("base")
	spr.animation = "default"
	anim_player.play("Pass_2")


func throw_3(passed: bool):
	set_active_path("result")
	if passed:
		anim_player.play("Pass_3")
	else:
		anim_player.play("Pass_Fail")

#	#FIXME: Hack

	await anim_player.animation_finished
	queued_for_deletion.emit()
	queue_free()
	visible = false
	##


func set_active_path(which):
	for k in remote_transforms.keys():
		remote_transforms[k].update_position = k == which

func _process(delta):
	if timestamp > max_input_threshold and not _handled:
		_handled = true
		emit_signal("failure")

func check_input():
	if _handled:
		return

	if timestamp >= min_input_threshold and timestamp <= max_input_threshold:
		_handled = true
		emit_signal("success")
	elif timestamp < min_input_threshold and (min_input_threshold - timestamp) < (max_input_threshold - min_input_threshold):
		#early fail hit
		_handled = true
		emit_signal("failure")

func _on_animation_finished(anim_name: String):
	if anim_name == "Pass_3" or anim_name == "Pass_Fail":
		queue_free()


func _unhandled_input(event):
	if (
		event.is_action_pressed("c_interact")
		or event.is_action_pressed("interact") and not _handled
	):
		check_input()
