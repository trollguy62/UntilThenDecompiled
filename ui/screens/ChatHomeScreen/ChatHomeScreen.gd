extends "../Screen.gd"

const DUMMY_ITEM_COUNT := 6

const Conversation = preload("res://data/story/Conversation.gd")
const ConversationItem = preload("res://ui/components/ConversationItem/ConversationItem.tscn")
const DummyConversationItem = preload("res://ui/components/DummyConversationItem/DummyConversationItem.tscn")
const ChatHandler = preload("res://components/ChatHandler.gd")

@onready var chat_handler: ChatHandler = Service.of("ChatHandler")
@onready var convo_list = $Main/ScrollContainer/ConversationList


func _ready():
	assert(chat_handler != null)

	for i in range(DUMMY_ITEM_COUNT):
		convo_list.add_child(DummyConversationItem.instantiate())

	for conversation in chat_handler.ordered_conversations():
		_on_conversation_added(conversation)

	chat_handler.conversation_added.connect(_on_conversation_added)
	chat_handler.conversation_updated.connect(_on_conversation_updated)


func _on_conversation_added(conversation: Conversation):
	var convo_item = ConversationItem.instantiate()
	convo_item.conversation = conversation
	convo_list.add_child(convo_item)
	convo_list.move_child(convo_item, chat_handler.conversations.size() - 1)

func _after_show():
	super._after_show()
	await get_tree().process_frame
	convo_list.get_child(0).call_deferred("grab_focus")
	for convo_item in convo_list.get_children():
		if "enabled" in convo_item:
			convo_item.enabled = true

func _on_conversation_updated(conversation: Conversation):
	for convo_item in convo_list.get_children():
		if convo_item.get("conversation") == conversation:
			convo_list.move_child(convo_item, 0)
			return
