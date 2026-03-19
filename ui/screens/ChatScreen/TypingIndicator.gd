extends RichTextLabel

const Set = preload("res://data/Set.gd")
const Conversation = preload("res://data/story/Conversation.gd")

@onready var tween = Threen.new()

var conversation: Conversation:
	set = _set_conversation,
	get = _get_conversation


func _ready():
	add_child(tween)
	modulate.a = 0


func _set_conversation(value):
	if conversation:
		conversation.typing_list_changed.disconnect(_update)

	conversation = value
	conversation.typing_list_changed.connect(_update)
	call_deferred("_update")


func _get_conversation():
	return conversation


func _update():
	var s = ""
	var chars: Set = conversation.typing_list

	if chars.size() == 1:
		s = tr("CHAT_IS_TYPING") % [chars.at(0).first_name]
	elif chars.size() == 2:
		s = tr("CHAT_ARE_TYPING") % [chars.at(0).first_name, chars.at(1).first_name]
	elif chars.size() > 2:
		s = tr("CHAT_SEVERAL_TYPING")

	set_bbcode(s)


func set_bbcode(bbcode: String):
	var len0 = text.length()
	var len1 = bbcode.length()

	if len0 > 0 and len1 == 0:  # Hide
		await _anim_alpha(false)
		text = bbcode
	elif len0 == 0 and len1 > 0:  # Show
		text = bbcode
		_anim_alpha(true)
	else:
		text = bbcode


func _anim_alpha(show):
	var c0 = modulate
	var c1 = c0
	c1.a = 1 if show else 0

	tween.interpolate_property(self, "modulate", c0, c1, 0.1, Threen.TRANS_LINEAR, Threen.EASE_IN)
	tween.start()
	await tween.tween_completed
