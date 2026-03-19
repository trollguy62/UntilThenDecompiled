extends "BaseMessage.gd"

const TextMessage = preload("res://ui/components/TextMessage/TextMessage.tscn")
const KeystrokeText = preload("res://data/KeystrokeText.gd")

const CORNER_RADIUS_SMALL = 4
const CORNER_RADIUS_BIG = 20

var typing_speed: float:
	get: return typing_speed

var _stylebox_hoop := StyleBoxFlat.new()
var _link_url := ""


func _init(sender: Character, text: String, typing_speed: float, tags: Dictionary):
	super("text", sender, text, tags)
	self.typing_speed = typing_speed

	_stylebox_hoop.content_margin_left = 16
	_stylebox_hoop.content_margin_right = 16
	_stylebox_hoop.content_margin_top = 12
	_stylebox_hoop.content_margin_bottom = 12

	_link_url = tags.get("link_url", "")


func get_control(conversation):
	var from_player = is_from_player(conversation)
	_stylebox_hoop.bg_color = conversation.color if from_player else Color("#F0F0F0")

	var group = conversation.group_of(self)
	var grp_prev = group == GROUP_MIDDLE or group == GROUP_END
	var grp_next = group == GROUP_MIDDLE or group == GROUP_START
	_stylebox_hoop.corner_radius_top_left = (
		CORNER_RADIUS_SMALL
		if not from_player and grp_prev
		else CORNER_RADIUS_BIG
	)
	_stylebox_hoop.corner_radius_bottom_left = (
		CORNER_RADIUS_SMALL
		if not from_player and grp_next
		else CORNER_RADIUS_BIG
	)
	_stylebox_hoop.corner_radius_top_right = (
		CORNER_RADIUS_SMALL
		if from_player and grp_prev
		else CORNER_RADIUS_BIG
	)
	_stylebox_hoop.corner_radius_bottom_right = (
		CORNER_RADIUS_SMALL
		if from_player and grp_next
		else CORNER_RADIUS_BIG
	)

	var msg = TextMessage.instantiate()
	msg.text = content
	msg.align_right = from_player
	msg.background_style = _stylebox_hoop

	if _link_url == "":
		msg.font_color = Color.WHITE if from_player else Color.BLACK
	else:
		msg.font_color = Color("#0000cc")
		msg.link_url = _link_url

	return msg


func set_content_to_final_text():
	content = KeystrokeText.new(content).final_text


func preview_str(conversation) -> String:
	if is_from_player(conversation):
		return tr("CHAT_HOME_PREVIEW_YOU") % content
	elif conversation.is_group_chat():
		return "%s: %s" % [sender.first_name, content]
	else:
		return content
