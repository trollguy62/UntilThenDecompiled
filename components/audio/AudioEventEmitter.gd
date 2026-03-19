@tool
extends Node
class_name AudioEventEmitter

const EVENTS_PATH = "res://addons/fmod/editor/resources/events"

enum PlayEventTrigger { None, OnReady, OnShow }
enum StopEventTrigger { None, OnHide }

@export var event_path := ""
@export var play_event: PlayEventTrigger
@export var stop_event: StopEventTrigger

@export_range(0.0, 4.0) var volume = 1.0
@export var playing := false
@export var autoplay := false
@export var paused := false

@export var allow_fadeout_when_stopping := true
@export var trigger_once := false


func as_studio_event_emitter() -> Node:
	var event := get_event_asset()
	if event == null:
		return null

	var emitter: Node

	if is_class("Node3D"):
		emitter = StudioEventEmitter3D.new()
	else:
		emitter = StudioEventEmitter2D.new()

	var transform = get("transform")
	if transform != null:
		emitter.transform = transform

	emitter.name = name
	emitter.event = event
	emitter.volume = volume
	emitter.playing = playing
	emitter.paused = paused
	emitter.allow_fadeout = allow_fadeout_when_stopping
	emitter.trigger_once = trigger_once

	if stop_event == StopEventTrigger.OnHide:
		emitter.stop_event = 5
	else:
		emitter.stop_event = RuntimeUtils.GAMEEVENT_EXIT_TREE

	if play_event == PlayEventTrigger.OnShow:
		emitter.play_event = 4
	elif autoplay or play_event == PlayEventTrigger.OnReady:
		emitter.play_event = RuntimeUtils.GAMEEVENT_READY
	else:
		emitter.play_event = RuntimeUtils.GAMEEVENT_NONE

	return emitter


func get_event_asset() -> EventAsset:
	for f in Utils.files_in_dir(EVENTS_PATH):
		var e = load(EVENTS_PATH+"/"+f) as EventAsset
		if e.path == event_path:
			return e

	printerr("Event %s not found" % event_path)
	return null
