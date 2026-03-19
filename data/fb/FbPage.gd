extends "FbMember.gd"

var category: String = "Page"
var description: String = ""
var like_count: int = 0
var liked = false


func _init(uid: String, json: Dictionary):
	super(uid, json)
	category = json.get("category", category)
	description = json.get("description", description)
	like_count = int(json.get("like_count", like_count))
	liked = bool(json.get("liked", liked))


func head_count_str() -> String:
	if like_count > 0:
		return FbUtils.count_and_noun_tr(like_count, "FB_MEMBER_HEAD_COUNT_LIKE")
	return ""


func sub_name_str() -> String:
	return category


func indicator_str() -> String:
	return "FB_MEMBER_IND_LIKED" if liked else ""
