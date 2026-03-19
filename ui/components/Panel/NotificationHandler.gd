extends MarginContainer

const State = preload("res://data/State.gd")
const PushNotification = preload("res://data/PushNotification.gd")
const PushNotificationView = preload("res://ui/components/PushNotification/PushNotification.tscn")

const SHOW_DURATION = 2.0
const EXTREME_SHOW_DURATION = 4.0
const ANIM_DURATION = 0.25

@onready var notif_control
@onready var container = $Container
@onready var tween = Threen.new()
@onready var dismiss_btn = $Container/DismissButton

var state: HandlerState:
	set = _set_state
var notif_queue := []


func _ready():
	add_child(tween)
	self.state = IdleState.new(self)


func _process(delta):
	var next_state = state._process(delta)
	if next_state != null:
		self.state = next_state


func _set_state(next_state):
	if state != null:
		state.exit()
	next_state.enter()
	state = next_state


func push(notif: PushNotification):
	dismiss_btn.visible = true

	match notif.priority:
		PushNotification.Priority.LOW:
			if state.idle:
				notif_queue.append(notif)
		PushNotification.Priority.MEDIUM:
			notif_queue.append(notif)
		PushNotification.Priority.HIGH, PushNotification.Priority.EXTREME:
			notif_queue.clear()
			notif_queue.append(notif)
		PushNotification.Priority.INEVITABLE:
			notif_queue.clear()
			notif_queue.append(notif)
			dismiss_btn.visible = false



func _anim_pos(from, to):
	tween.interpolate_property(
		self, "position", from, to, ANIM_DURATION, Threen.TRANS_QUAD, Threen.EASE_OUT
	)
	tween.start()


func _get_next_notif():
	return notif_queue.pop_front()


func _play_sound():
	$SoundNotification.play()


class HandlerState:
	extends State
	var handler
	var idle = false

	func _init(handler):
		self.handler = handler


class IdleState:
	extends HandlerState

	func _init(handler):
		super(handler)
		idle = true

	func _process(delta):
		var notif = handler._get_next_notif()
		if notif != null:
			return AppearingState.new(handler, notif)


class AppearingState:
	extends HandlerState
	var notif_control
	var done = false

	func _init(handler, notif):
		super(handler)
		notif_control = PushNotificationView.instantiate()
		notif_control.notif = notif

	func enter():
		handler.container.add_child(notif_control)
		handler.container.move_child(notif_control, 0)
		handler._play_sound()

		handler.modulate.a = 0
		await handler.get_tree().process_frame
		handler.modulate.a = 1

		var to_pos = Vector2.ZERO
		var from_pos = Vector2(0, -handler.size.y)
		handler._anim_pos(from_pos, to_pos)

		await handler.tween.tween_completed
		done = true

	func _process(delta):
		if done:
			return WaitingState.new(handler, notif_control)


class WaitingState:
	extends HandlerState
	var notif_control
	var done = false

	func _init(handler, notif_control):
		super(handler)
		self.notif_control = notif_control

	func enter():
		handler.dismiss_btn.disabled = false
		notif_control.disabled = false
		handler.dismiss_btn.pressed.connect(_dismiss)
		notif_control.opened.connect(_dismiss)

		var notif = notif_control.notif
		var show_dur = (
			EXTREME_SHOW_DURATION
			if notif.priority == PushNotification.Priority.EXTREME
			else SHOW_DURATION
		)

		if notif.priority == PushNotification.Priority.INEVITABLE:
			await notif_control.opened
		else:
			await Utils.wait(show_dur)
			done = true

	func _dismiss():
		done = true

	func _process(delta):
		if done:
			return DismissingState.new(handler, notif_control)

	func exit():
		handler.dismiss_btn.disabled = true
		notif_control.disabled = true
		handler.dismiss_btn.pressed.disconnect(_dismiss)
		notif_control.opened.disconnect(_dismiss)


class DismissingState:
	extends HandlerState
	var notif_control
	var done = false

	func _init(handler, notif_control):
		super(handler)
		self.notif_control = notif_control

	func enter():
		var from_pos = Vector2.ZERO
		var to_pos = Vector2(0, -handler.size.y)
		handler._anim_pos(from_pos, to_pos)

		await handler.tween.tween_completed
		notif_control.queue_free()
		done = true

	func _process(delta):
		if done:
			return IdleState.new(handler)
