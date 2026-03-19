extends PanelContainer

const Conversation = preload("res://data/story/Conversation.gd")

@onready var button = $Button
@onready var h_box = $MarginContainer/HBox
@onready var picture = h_box.get_node("Picture")
@onready var title = h_box.get_node("Info/Title")
@onready var subtitle = h_box.get_node("Info/Subtitle")

var conversation: Conversation
var enabled: bool = true:
	set(v):
		enabled = v
		button.disabled = not enabled

func _ready():
	assert(conversation != null)
	conversation.message_added.connect(_on_message_added)
	conversation.advanced.connect(_on_advanced)
	button.pressed.connect(_on_pressed)
	_update()


func _update():
	picture.texture = conversation.picture
	title.text = conversation.name

	var last_message = conversation.last_message_str()
	subtitle.text = last_message
	subtitle.visible = last_message.length() > 0

	#button.idle_alpha = 0.1 if conversation.is_awaiting_player_input() else 0

func grab_focus():
	button.disabled = false
	button.grab_focus()
	button.grab_click_focus()

func _on_message_added(message):
	_update()

func _on_advanced():
	_update()

func _on_pressed():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		button.disabled = true
		navigator.push_named("/chat", {"conversation": conversation})
		button.release_focus()
