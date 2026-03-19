extends Node

signal conversation_added(conversation)
signal conversation_updated(conversation)
signal conversation_completed(conversation)

const Conversation = preload("res://data/story/Conversation.gd")
const Set = preload("res://data/Set.gd")
const BaseMessage = preload("res://data/BaseMessage.gd")
const TextMessage = preload("res://data/TextMessage.gd")
const KeystrokeText = preload("res://data/KeystrokeText.gd")
const PushNotification = preload("res://data/PushNotification.gd")

const NOTIF_ICON = preload("res://assets/ui/ic_message_black.png")

var conversations := Set.new():
	get: return conversations

var _message_processors = []


func _init():
	_message_processors.append(DefaultMessageProcessor.new())
	_message_processors.append(CharacterTextMessageProcessor.new())


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		conversations.clear()


func start(conversation: Conversation):
	if conversations.has(conversation):
		print("ChatHandler already handles conversation")
	elif conversation.started:
		print("Conversation already started")
	else:
		conversations.add(conversation)
		conversation_added.emit(conversation)

		conversation.advanced.connect(_on_advanced.bind(conversation))
		conversation.message_added.connect(_on_new_message.bind(conversation))
		conversation.advance()


func send_message_then_advance(conversation: Conversation, message):
	if message != null:
		await conversation.add_message(message)
	else:
		await conversation.wait_natural_delay()

	conversation.advance()


func _on_advanced(conversation: Conversation):
	var processed = await _proc_current(conversation)

	if processed:
		if conversation.is_done():
			conversation_completed.emit(conversation)
			conversation.finish()
			conversations.remove(conversation)
		else:
			# Deferred to let other `advanced` listeners be called, avoids clogging
			conversation.call_deferred("advance")

	# If not processed, others can handle the current object and advance the convo (i.e. ChatScreen)


func _on_new_message(message, conversation: Conversation):
	conversation_updated.emit(conversation)
	_try_notify_on_new_message(message, conversation)


# Push new message notification (under a lot of conditions)
func _try_notify_on_new_message(message, conversation: Conversation):
	var local_priority = message.tags.get("notify", -1)
	var local_route = message.tags.get("route", "")
	var local_payload = message.tags.get("payload", {})
	var global_priority = conversation.notif_priority
	var notif_priority = max(local_priority, global_priority)
	if notif_priority < 0:
		return

	if message.is_from_player(conversation):
		return

	var notifier = Service.of(Service.NOTIFIER)
	var navigator = Service.of(Service.NAVIGATOR)
	if notifier == null or navigator == null:
		return

	var top_screen = navigator.top()
	if top_screen == null:
		return

	var screen_type = top_screen.meta.get("type", "")
	var screen_convo_id = top_screen.meta.get("conversation_id", "")
	var in_conversation = screen_type == "chat"  and screen_convo_id == conversation.id

	if screen_type == "chat_home" or in_conversation:
		return

	if local_route == "/chat":
		local_payload = message.tags
		local_payload["conversation"] = conversation

	var notif = PushNotification.new(
		NOTIF_ICON,
		"Chat",
		conversation.name,
		conversation.last_message_str(),
		notif_priority,  #,
		local_route,
		local_payload
		# TODO creates duplicate screens, messes stuff up
	)

	notifier.push(notif)


func get_conversation_with_id(id: String) -> Conversation:
	for conversation in conversations.to_array():
		if conversation.id == id:
			return conversation
	return null


func ordered_conversations() -> Array:
	var ordered = conversations.to_array()
	ordered.sort_custom(func(a, b): return a.last_message_time > b.last_message_time)
	return ordered


func _proc_current(conversation: Conversation) -> bool:
	var current = conversation.current
	var call

	if current is BaseMessage:
		call = await _proc_message(conversation, current)
	elif current is Command:
		call = await conversation.run_command(current)

	if current is Command:
		call = typeof(call) != TYPE_OBJECT or call != Constants.CMD_RETURN_NONE

	return call == true # Explicit check is intentional


func _proc_message(conversation: Conversation, msg: BaseMessage) -> bool:
	for processor in _message_processors:
		var send = await processor.process(conversation, msg)
		if send:
			return true

	return false


class MessageProcessor:
	const Conversation = preload("res://data/story/Conversation.gd")
	const BaseMessage = preload("res://data/BaseMessage.gd")

	func process(conversation: Conversation, msg: BaseMessage) -> bool:
		return false


class DefaultMessageProcessor:
	extends MessageProcessor
	const PictureMessage = preload("res://data/PictureMessage.gd")
	const SystemMessage = preload("res://data/SystemMessage.gd")

	func process(conversation: Conversation, msg: BaseMessage) -> bool:
		var sender = msg.sender
		var player = conversation.player

		if conversation.compose_mode and sender != player:
			print("A non-player message was skipped during compose mode")
			return true

		if conversation.instant:
			if msg is TextMessage:
				msg.set_content_to_final_text()
			conversation.add_message(msg)
		elif msg is PictureMessage or msg is SystemMessage:
			await conversation.add_message(msg)
		else:
			return false

		return true


class CharacterTextMessageProcessor:
	extends MessageProcessor
	const TextMessage = preload("res://data/TextMessage.gd")
	const AccurateDelaySource = preload("res://components/AccurateDelaySource.gd")

	func process(conversation: Conversation, msg: BaseMessage) -> bool:
		if not msg is TextMessage or msg.is_from_player(conversation):
			return false

		var delay_mult = Game.config.text_speed_delay_mult
		var base_kps = _get_base_kps(msg.typing_speed)
		var kps = randfn(base_kps, 0.1)
		var spk = 1 / max(0.1, kps)

		var sender = msg.sender
		var keystr = KeystrokeText.new(msg.content)
		var typing_list = conversation.typing_list

		var delay_src = AccurateDelaySource.new()

		sender.focus_on(conversation)
		msg.set_content_to_final_text()

		for inst in keystr.steps:
			var delay = spk

			if inst is KeystrokeText.TextInst:
				typing_list.add(sender)
			elif inst is KeystrokeText.DelayInst:
				delay = inst.delay * delay_mult
				typing_list.remove(sender)
			elif inst is KeystrokeText.FillInst:
				delay = inst.duration * delay_mult
				typing_list.add(sender)

			if inst is Command:
				await conversation.context.run_command(inst)
			else:
				await delay_src.delay(delay)

		typing_list.remove(sender)
		if not msg.content.is_empty():
			await conversation.add_message(msg)

		return true

	# Apply weighted offset to character typing speed based on text speed setting
	func _get_base_kps(typing_speed: float) -> float:
		var weight = Game.config.text_speed
		var offset = lerp(-5, 5, weight)
		return max(1.0, typing_speed + offset)
