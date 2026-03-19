extends "BaseMessage.gd"

const PictureMessage = preload("res://ui/components/PictureMessage/PictureMessage.tscn")

var _sticker := false


func _init(sender: Character, picture: Texture, tags: Dictionary):
	super("pic", sender, picture, tags)
	_sticker = tags.get("sticker", false)


func get_control(conversation):
	var control = PictureMessage.instantiate()
	control.picture = content as Texture
	control.align_right = is_from_player(conversation)
	control.sticker = _sticker
	return control


func preview_str(conversation) -> String:
	if is_from_player(conversation):
		return tr("CHAT_PREVIEW_SENT_STICKER_YOU" if _sticker else "CHAT_PREVIEW_SENT_PHOTO_YOU")
	else:
		var str = tr("CHAT_PREVIEW_SENT_STICKER_OTHER" if _sticker else "CHAT_PREVIEW_SENT_PHOTO_OTHER")
		return str % [sender.first_name]
