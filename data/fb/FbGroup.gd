extends "FbMember.gd"

enum { GROUP_TYPE_PUBLIC, GROUP_TYPE_CLOSED, GROUP_TYPE_SECRET }

var description: String = ""
var type = GROUP_TYPE_PUBLIC
var member_count: int = 0
var joined = false


func _init(uid: String, json: Dictionary):
	super(uid, json)
	description = json.get("description", description)
	type = int(json.get("type", type))
	member_count = int(json.get("member_count", member_count))
	joined = bool(json.get("joined", joined))


func head_count_str() -> String:
	if member_count > 0:
		return FbUtils.count_and_noun_tr(member_count, "FB_MEMBER_HEAD_COUNT_MEMBER")
	return ""


func sub_name_str() -> String:
	match type:
		GROUP_TYPE_PUBLIC:
			return "FB_MEMBER_GROUP_TYPE_PUBLIC"
		GROUP_TYPE_CLOSED:
			return "FB_MEMBER_GROUP_TYPE_CLOSED"
		GROUP_TYPE_SECRET:
			return "FB_MEMBER_GROUP_TYPE_SECRET"
		_:
			return ""


func indicator_str() -> String:
	return "FB_MEMBER_IND_JOINED" if joined else ""
