extends "Substory.gd"

signal message_added(message: String)
signal online_changed(online)
#warning-ignore:unused_signal
signal typing_list_changed
#warning-ignore:unused_signal
signal seen_by_changed
signal composition_cleared
signal composition_erased_last

const BaseMessage = preload("res://data/BaseMessage.gd")
const TextMessage = preload("res://data/TextMessage.gd")
const SystemMessage = preload("res://data/SystemMessage.gd")
const PictureMessage = preload("res://data/PictureMessage.gd")
const PushNotification = preload("res://data/PushNotification.gd")
const KeystrokeText = preload("res://data/KeystrokeText.gd")
const Set = preload("res://data/Set.gd")

var name: String:
	get = _get_name, set = _set_name

var picture: Texture:
	get: return picture if picture != null else other.profile_picture

var other: Character:
	get: return self.participants[0]

var participants: Array:
	get:
		var chars = sorted_characters()
		chars.erase(player)
		return chars

var color: Color
var natural_delay: float
var notif_priority: int
var hide_info_button: bool
var messages: Array = []
var typing_list: Set = Set.new()
var online := true
var instant := false

var composition: Array = []
var compose_mode: bool
var msg: TextMessage
var request_send: Callable

# Set of characters who have seen the last message
# Clears every new message
var _seen_by := Set.new()
var seen_by: Set:
	get = _get_seen_by_filtered

var last_message_time := Time.get_ticks_msec():
	get: return last_message_time


func _init(
	id: String,
	runner: InkRunner,
	header: Dictionary = {},
	context: SubstoryContext = null
):
	super(id, runner, header, context)
	assert(header.type == "chat")

	_add_parser(_conversation_parser)
	_add_command_handler(_conversation_command_handler)

	name = header.get("name", "")
	color = Color(header.get("color", "#0099FF"))
	natural_delay = header.get("natural_delay", 0.75)
	notif_priority = header.get("notify", -1)
	hide_info_button = header.get("hide_info_button", false)

	for character in characters.values():
		character.focus_on(self)

	if "picture" in header:
		picture = load(header.picture)

	_init_signals()


func get_custom_class() -> String:
	return "Conversation"


func _init_signals():
	_seen_by.changed.connect(func(): seen_by_changed.emit())
	typing_list.changed.connect(func(): typing_list_changed.emit())

	for participant in self.participants:
		participant.online_changed.connect(_on_char_online_changed.bind(participant))
		participant.conversation_focus_changed.connect(_on_char_conversation_focus_changed.bind(participant))


func start():
	var handler = Service.of("ChatHandler")
	handler.start(self)
	await finished


func _get_name() -> String:
	if name != null and name.length() > 0:
		return name

	if is_group_chat():
		var n = ""
		var participants = self.participants

		for i in range(min(3, participants.size())):
			n += participants[i].first_name + ", "

		return n.trim_suffix(", ")
	else:
		return self.other.full_name


func _set_name(value):
	name = value


func is_group_chat():
	return _character_map.size() > 2


func is_last_message_from_player():
	if messages.is_empty():
		return false
	else:
		return messages.back().is_from_player(self)


func sorted_characters() -> Array:
	var chars = characters.values()
	chars.sort_custom(func(a, b): return a.full_name < b.full_name)
	return chars


func index_of(message):
	return messages.find(message)


func neighbors_of(message):
	var i = index_of(message)
	var neighbors = [null, null]
	if i < 0:
		return neighbors

	if i - 1 >= 0:
		neighbors[0] = messages[i - 1]
	if i + 1 < messages.size():
		neighbors[1] = messages[i + 1]

	return neighbors


func group_of(message):
	var neighbors = neighbors_of(message)
	var prev = neighbors[0]
	var next = neighbors[1]

	var grp_prev = prev != null and prev.is_grouped_with(message)
	var grp_next = next != null and next.is_grouped_with(message)

	match [grp_prev, grp_next]:
		[false, false]:
			return BaseMessage.GROUP_SINGLE
		[true, true]:
			return BaseMessage.GROUP_MIDDLE
		[false, true]:
			return BaseMessage.GROUP_START
		[true, false]:
			return BaseMessage.GROUP_END


# TODO some of these functions are better off with ChatHandler
func add_message(message: BaseMessage):
	last_message_time = Time.get_ticks_msec()
	messages.append(message)
	message_added.emit(message)
	_seen_by.clear()

	if instant:
		return

	if message.sender != null:
		message.sender.focus_on(self)
		await _wait_last_message_seen()

	await wait_natural_delay()


# Wait last message to be marked as seen by focused characters
func _wait_last_message_seen():
	assert(not messages.is_empty())
	await Utils.wait(0)
	# Instantly mark as seen for player, if focused, and sender
	if player.is_focused_on(self):
		_seen_by.add(player)

	var last_msg_sender = messages.back().sender
	_seen_by.add(last_msg_sender)

	var shuffled_chars = characters.values()
	shuffled_chars.shuffle()

	for chr in shuffled_chars:
		if not _seen_by.has(chr) and chr.is_focused_on(self):
			var delay = randf_range(0.1, 0.3)
			await Utils.wait(delay)
			_seen_by.add(chr)


# Exclude character and last message sender
func _get_seen_by_filtered():
	var ret = Set.new()
	for character in _seen_by.to_array():
		ret.add(character)

	ret.remove(player)
	if not messages.is_empty():
		ret.remove(messages.back().sender)

	return ret


func wait_natural_delay():
	var delay = 0
	if natural_delay > 0:
		delay = max(0, randfn(natural_delay, 0.1))
	await Utils.wait(delay)


func _on_char_online_changed(character):
	_update_online()
	_mark_seen_if_focused(character)


func _on_char_conversation_focus_changed(character):
	_mark_seen_if_focused(character)


func _update_online():
	var new_online = false
	for participant in self.participants:
		if participant.online:
			new_online = true
			break

	if new_online != online:
		online = new_online
		online_changed.emit(online)


func _mark_seen_if_focused(character):
	if character.is_focused_on(self):
		_seen_by.add(character)


func seen_by_str() -> String:
	var seen_by_filtered = _get_seen_by_filtered()
	var s = ""

	if is_group_chat():
		if _seen_by.size() == characters.size():
			s = tr("CHAT_SEEN_BY_EVERYONE")
		elif not seen_by_filtered.is_empty():
			var first_names = PackedStringArray()
			for character in seen_by_filtered.to_array():
				first_names.append(character.first_name)

			s += tr("CHAT_SEEN_BY") + " "

			if first_names.size() <= 3:
				s += ", ".join(first_names)
			else:
				s += (
					tr("CHAT_SEEN_AND_OTHERS")
					% [first_names[0], first_names[1], first_names.size() - 2]
				)
	elif not seen_by_filtered.is_empty():
		s = tr("CHAT_SEEN")

	return s


func last_message_str() -> String:
	if messages.is_empty():
		return ""

	for i in range(messages.size(), 0, -1):
		var msg = messages[i - 1]
		var preview: String = msg.preview_str(self)
		if preview.length() > 0:
			return preview

	return ""


func is_awaiting_player_input() -> bool:
	return current is Array or (current is TextMessage and current.is_from_player(self))


func _conversation_parser(raw: String):
	var result := Constants.REGEX_CHAT.search(raw)
	if result == null:
		return null

	var sender_key = result.strings[1]
	var content = result.strings[2]
	var sender = characters.get(sender_key)

	if sender_key == SystemMessage.SENDER_KEY:
		return SystemMessage.new(content, current_tags)
	elif current_tags.get("type") == "picture":
		var picture = load(content)
		return PictureMessage.new(sender, picture, current_tags)
	else:
		var typing_speed = tag_value(sender_key, "typing_speed", Character.DEFAULT_TYPING_SPEED)
		return TextMessage.new(sender, content, typing_speed, current_tags)


func _conversation_command_handler(cmd: Command):
	match cmd.name:
		"online":
			_exec_cmd_online(cmd.params)
		"set_online":
			_exec_cmd_set_online(cmd.params)
		"start_instant":
			instant = true
		"end_instant":
			instant = false
		"chat_compose_enter":
			compose_mode = true
		"chat_compose_exit":
			await request_send.call()
			compose_mode = false
			composition_cleared.emit()
			await add_message(msg)
		"chat_compose_erase_last":
			composition_erased_last.emit()
		_:
			return Constants.CMD_RETURN_NONE

	return null


func _exec_cmd_online(params: Array):
	for op_raw in params:
		var op = Set.get_operation(op_raw)
		var chr = characters.get(op.flag)
		if chr == null:
			return

		match op.type:
			Set.OP_TYPE_ADD:
				chr.online = true
			Set.OP_TYPE_REMOVE:
				chr.online = false
			Set.OP_TYPE_INVERT:
				chr.online = not chr.online


func _exec_cmd_set_online(params: Array):
	for chr_key in characters:
		var chr = characters[chr_key]
		chr.online = chr_key in params
