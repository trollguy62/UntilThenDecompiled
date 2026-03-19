extends MarginContainer

const GROUP_SEPARATION = 4
const Conversation = preload("res://data/story/Conversation.gd")
const BaseMessage = preload("res://data/BaseMessage.gd")

var conversation: Conversation
var message: BaseMessage

@onready var name_container = $VBox/NameContainer
@onready var message_container = $VBox/MessageContainer
@onready var name_label = $VBox/NameContainer/Name
@onready var profile_picture = $VBox/MessageContainer/ProfilePicture


func _ready():
	update()


func update():
	queue_redraw()

	var group = conversation.group_of(message)
	var from_player = message.is_from_player(conversation)

	name_container.visible = false
	profile_picture.visible = false

	_update_margins(group)
	set_child(message.get_control(conversation))

	if message.sender == null:
		return

	name_label.text = message.sender.first_name
	profile_picture.texture = message.sender.profile_picture

	if conversation.is_group_chat() and not from_player:
		var show_name = group == BaseMessage.GROUP_START or group == BaseMessage.GROUP_SINGLE
		var show_pic = group == BaseMessage.GROUP_END or group == BaseMessage.GROUP_SINGLE

		name_container.visible = show_name
		profile_picture.visible = true
		profile_picture.modulate.a = 1 if show_pic else 0


func _update_margins(group):
	var detach_prev = group == BaseMessage.GROUP_SINGLE or group == BaseMessage.GROUP_START
	var detach_next = group == BaseMessage.GROUP_SINGLE or group == BaseMessage.GROUP_END
	set("theme_override_constants/margin_top", GROUP_SEPARATION if detach_prev else 0)
	set("theme_override_constants/margin_bottom", GROUP_SEPARATION if detach_next else 0)


func set_child(child: Control):
	if message_container.get_child_count() == 2:
		var prev_control = message_container.get_child(1)
		if prev_control != null:
			#preserve this line so the control doesnt appear for 1 frame before queue_free
			message_container.remove_child(prev_control)
			#
		prev_control.queue_free()
	message_container.add_child(child)
