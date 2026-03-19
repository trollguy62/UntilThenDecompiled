extends "../Screen.gd"

const SCROLL_END_SEEN_THRESHOLD = 150

const Conversation = preload("res://data/story/Conversation.gd")
const Choice = preload("res://data/Choice.gd")

const Character = preload("res://data/Character.gd")
const TextMessage = preload("res://data/TextMessage.gd")
const SystemMessage = preload("res://data/SystemMessage.gd")
const PictureMessage = preload("res://data/PictureMessage.gd")
const PushNotification = preload("res://data/PushNotification.gd")
const KeystrokeText = preload("res://data/KeystrokeText.gd")
const MessageScaffold = preload("res://ui/components/MessageScaffold/MessageScaffold.tscn")

@onready var convo_picture = $Main/ProfilePicture
@onready var convo_name = $Main/NameContainer/Name
@onready var convo_status = $Main/StatusContainer/Status
@onready var chatbox = $Main/Chatbox
@onready var typing_indicator = $Main/TIContainer/TypingIndicator
@onready var choice_text_field = $Main/ChoiceTextField
@onready var info_btn = $InfoButton
@onready var seen_by_container = $SeenByContainer
@onready var seen_by_label = $SeenByContainer/SeenBy
@onready var new_messages_btn = $NewMessagesButton
@onready var back_btn = $BackButton

var conversation: Conversation
var scroll_end_seen := true
var hide_back_btn := false:
	set(v):
		if not is_inside_tree():
			await ready
		back_btn.visible = not v
		hide_back_btn = v


func _ready():
	info_btn.gui_input.connect(_on_info_btn_gui_input)
	info_btn.pressed.connect(_on_info_btn_pressed)
	new_messages_btn.pressed.connect(_on_new_messages_btn_pressed)

	if hide_back_btn:
		back_btn.visible = false

	if conversation.hide_info_button:
		info_btn.visible = false

	_init_seen_by()
	call_deferred("_start")


func _init_seen_by():
	remove_child(seen_by_container)
	chatbox.footer = seen_by_container


func _start():
	_load()

	conversation.request_send = choice_text_field.request_send

	conversation.message_added.connect(_on_message_added)
	conversation.online_changed.connect(_on_online_changed)
	conversation.seen_by_changed.connect(_on_seen_by_changed)
	conversation.advanced.connect(_on_advanced)
	conversation.composition_cleared.connect(_on_composition_cleared)
	conversation.composition_erased_last.connect(_on_composition_erased_last)

	choice_text_field.run_command = conversation.context.run_command


func _before_hide():
	back_btn.release_focus()
	back_btn.disabled = true

func _before_show():
	info_btn.disabled = false
	back_btn.disabled = true

func _after_show():
	super._after_show()
	#FIXME: Hack. fixes a bug due to back btn being accessible before pop or push animation completes
	back_btn.disabled = false

# Load existing state
func _load():
	convo_picture.texture = conversation.picture
	convo_name.text = conversation.name
	typing_indicator.conversation = conversation

	var auto_scroll_weight = chatbox.auto_scroll_weight
	chatbox.auto_scroll_weight = 99.0  # TODO 1.0 doesn't cut it, why??

	for message in conversation.messages:
		_add_message_view(message)
	scroll_end_seen = true

	await get_tree().process_frame
	chatbox.scroll_to_end()
	_on_online_changed(conversation.online)
	_on_seen_by_changed()
	_on_advanced()

	await get_tree().process_frame
	chatbox.scroll_to_end()
	chatbox.auto_scroll_weight = auto_scroll_weight
	chatbox.lock_end = true
	chatbox.animate_entry = true


func _process(_delta):
	if chatbox.scroll_end_offset() <= SCROLL_END_SEEN_THRESHOLD:
		scroll_end_seen = true
	new_messages_btn.show = not scroll_end_seen


func _on_advanced():
	var current = conversation.current

	if current is TextMessage and current.is_from_player(conversation):
		await _proc_player_text_message(current)
	elif current is Array:
		await _proc_choices(current)


func _proc_player_text_message(msg: TextMessage):
	if conversation.instant:
		await Utils.wait(0)
		return

	assert(msg.is_from_player(conversation))
	choice_text_field.text_message = msg.content
	choice_text_field.compose_mode = conversation.compose_mode
	msg.content = await choice_text_field.text_message_sent

	if choice_text_field.prev_state == "PreSendState":
		back_btn.disabled = true
		get_tree().create_timer(1.0).timeout.connect(func(): back_btn.disabled = false)

	if conversation.compose_mode:
		msg.content = choice_text_field.get_composition()
		conversation.msg = msg
		conversation.advance()
		return

	var handler = Service.of("ChatHandler")
	# TODO refactor (transfer more responsibility from Conversation to ChatHandler?)
	if msg.content.length() > 0:
		handler.send_message_then_advance(conversation, msg)
		await get_tree().process_frame
		chatbox.scroll_to_end()
	else:
		handler.send_message_then_advance(conversation, null)


func _proc_choices(ink_choices: Array):
	#FIXME: hack. Temporarily disable back button while a  choice is underway
	back_btn.disabled = true
	var choices = []

	for ink_choice in ink_choices:
		var choice = Choice.new(ink_choice)
		choices.append(choice)

	choice_text_field.choices = choices
	var choice_idx = await choice_text_field.chosen

	conversation.choose_choice_index(choice_idx)
	conversation.advance()
	back_btn.disabled = false


func _add_message_view(message):
	var scaffold = MessageScaffold.instantiate()
	scaffold.conversation = conversation
	scaffold.message = message

	chatbox.add_list_item(scaffold)
	_update_neighbors_of(conversation.messages.size() - 1)
	scroll_end_seen = false


func _on_message_added(message):
	_add_message_view(message)
	if not conversation.instant:
		$SoundPop.play()


func _update_neighbors_of(i):
	var prev = chatbox.list_item_at(i - 1)
	var next = chatbox.list_item_at(i + 1)

	if prev != null and prev.has_method("update"):
		prev.update()
	if next != null and next.has_method("update"):
		next.update()


func _on_online_changed(online):
	convo_status.text = "CHAT_ACTIVE_NOW" if online else "CHAT_OFFLINE"


func _on_seen_by_changed():
	var seen_by_str = conversation.seen_by_str()
	var old_visible = seen_by_container.visible
	var new_visible = not seen_by_str.is_empty()
	var align_right = conversation.is_last_message_from_player()

	seen_by_container.visible = new_visible
	seen_by_label.text = seen_by_str
	seen_by_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT \
		if align_right else HORIZONTAL_ALIGNMENT_LEFT

	var scroll_to_end = chatbox.should_autoscroll_to_end() and not old_visible and new_visible

	if scroll_to_end:
		await get_tree().process_frame
		chatbox.scroll_to_end()

func _on_info_btn_gui_input(event):
	if event.is_action("interact") and not event.pressed:
		#(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
		get_viewport().set_input_as_handled()
		_on_info_btn_pressed()

func _on_info_btn_pressed():
	info_btn.disabled = true
	navigator.push_named("/chat/info", {"conversation": conversation})



func _on_new_messages_btn_pressed():
	chatbox.scroll_to_end()


func _on_composition_cleared():
	choice_text_field.clear_composition()


func _on_composition_erased_last():
	choice_text_field.composition_erase_last()

func _reset_default_focus():
	focus_on_enter.grab_focus()
	focus_on_enter.grab_click_focus()

func _unhandled_input(event):
	if not hide_back_btn and event.is_action_pressed("c_cancel"):
		back_btn.press()
		back_btn.disabled = true

	if event.is_action_pressed("ui_up"):
		if get_viewport().gui_get_focus_owner() == null:
			_reset_default_focus()
