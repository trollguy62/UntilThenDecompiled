extends "../Screen.gd"

const Conversation = preload("res://data/story/Conversation.gd")
const Character = preload("res://data/Character.gd")

const CharacterButton = preload("res://ui/components/CharacterButton/CharacterButton.tscn")

@onready var main = $Main
@onready var back_btn = $BackButton

@onready var convo_picture = main.get_node("Picture")
@onready var convo_name = main.get_node("NameContainer/Name")
@onready var convo_subtitle = main.get_node("SubtitleContainer/Subtitle")
@onready var header_label = main.get_node("HeaderContainer/Header")
@onready var view_profile_btn = $Main/ViewProfile
@onready var member_list_container = $Main/VScroll
@onready var member_list: VBoxContainer = $Main/VScroll.list_item_at(0)

var conversation: Conversation


func _ready():
	view_profile_btn.pressed.connect(_view_profile)
	conversation.online_changed.connect(_on_online_changed)

	convo_picture.texture = conversation.picture
	convo_name.text = conversation.name

	var is_group_chat = conversation.is_group_chat()
	member_list_container.visible = is_group_chat
	view_profile_btn.visible = not is_group_chat
	header_label.text = "CHAT_INFO_HEADER_MEMBERS" if is_group_chat else "CHAT_INFO_HEADER_ACTIONS"

	if is_group_chat:
		_load_members()

	_on_online_changed(conversation.online)

	back_btn.disabled = true


func _after_show():
	super._after_show()
	back_btn.disabled = false
	view_profile_btn.disabled = false


func _before_hide():
	super._before_hide()
	back_btn.disabled = true


func _on_online_changed(online):
	convo_subtitle.text = "CHAT_ACTIVE_NOW" if online else "CHAT_OFFLINE"


func _load_members():
	var first_btn

	for character in conversation.sorted_characters():
		var char_btn = CharacterButton.instantiate()
		char_btn.character = character
		member_list.add_child(char_btn)

		if first_btn == null:
			first_btn = char_btn

	first_btn.call_deferred("grab_focus")


func _view_profile():
	view_profile_btn.release_focus()
	var uid = conversation.other.fb_profile_uid
	navigator.push_named("fb://profiles/" + uid)

func _unhandled_input(event):
	if event.is_action_pressed("c_cancel"):
		back_btn.press()
