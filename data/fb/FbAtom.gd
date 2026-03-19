extends "FbQuark.gd"

signal comments_changed()

const FbComment = preload("FbComment.gd")

var caption: String
var shareable: bool
var share_count: int:
	get: return share_count + (1 if self.shared else 0)

var shared: bool:
	set(value): _dict.shared = value
	get: return bool(_dict.get("shared", false))

var comments: Dictionary

var bbcode_caption: String:
	get: return FbUtils.transform_bbcode_text(caption)

var comment_count: int:
	get:
		var displayed_comment_count = ordered_comments().size()
		if comment_count > 0 and displayed_comment_count > 0:
			return comment_count
		return displayed_comment_count


func _init(uid: String, json: Dictionary):
	super(uid, json)
	caption = json.get("caption", "")
	shareable = bool(json.get("shareable", true))
	share_count = int(json.get("share_count", 0))
	comment_count = int(json.get("comment_count", 0))

	comments = json.get("comments", {}).duplicate()
	for cid in comments.keys():
		comments[cid] = FbComment.new(cid, comments[cid])


func ordered_comments(displayed_only = true) -> Array:
	return FbUtils.get_ordered_comments(comments, displayed_only)


func choice_comments() -> Array:
	return FbUtils.get_choice_comments(comments)


func choose_comment(uid: String):
	for comment in comments.values():
		if not comment.is_choice():
			continue
		if comment.uid == uid:
			comment.choose()
		else:
			comment.block()
	comments_changed.emit()
