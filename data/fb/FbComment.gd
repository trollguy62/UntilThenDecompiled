extends "FbQuark.gd"

signal replies_changed

const FbQuark = preload("res://data/fb/FbQuark.gd")

const CHOICE_MODE_BLOCK = -1
const CHOICE_MODE_DISPLAY = 0
const CHOICE_MODE_OPTION = 1

var content: String
var picture_ref: String
var link: String
var replies: Dictionary

var bbcode_content: String:
	get: return FbUtils.transform_bbcode_text(content)

var reply_count: int: # Fake count
	get:
		var displayed_reply_count = ordered_replies().size()
		if reply_count > 0 and displayed_reply_count > 0:
			return reply_count
		return displayed_reply_count


func _init(uid: String, json: Dictionary):
	super(uid, json)
	content = json.get("content", "")
	picture_ref = json.get("picture_ref", "")
	link = json.get("link", "")
	reply_count = json.get("reply_count", 0)

	replies = json.get("replies", {}).duplicate()
	for rid in replies.keys():
		replies[rid] = get_script().new(rid, replies[rid])


func ordered_replies(displayed_only = true) -> Array:
	return FbUtils.get_ordered_comments(replies, displayed_only)


func choice_replies() -> Array:
	return FbUtils.get_choice_comments(replies)


func choose_reply(uid: String):
	for reply in replies.values():
		if not reply.is_choice():
			continue
		if reply.uid == uid:
			reply.choose()
		else:
			reply.block()
	replies_changed.emit()


func choice_preview() -> String:
	return _dict.get("choice_preview", content)


func is_displayed() -> bool:
	return _get_choice_mode() == CHOICE_MODE_DISPLAY


func is_choice() -> bool:
	return _get_choice_mode() == CHOICE_MODE_OPTION


func choose():
	_dict.choice_mode = CHOICE_MODE_DISPLAY
	self.timestamp = Game.time


func block():
	_dict.choice_mode = CHOICE_MODE_BLOCK


func _get_choice_mode() -> int:
	return _dict.get("choice_mode", CHOICE_MODE_DISPLAY)
