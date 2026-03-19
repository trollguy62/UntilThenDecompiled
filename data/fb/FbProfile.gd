extends "FbMember.gd"

enum {
	REL_STATUS_NONE = 0,
	REL_STATUS_SINGLE,
	REL_STATUS_TAKEN,
	REL_STATUS_COMPLICATED,
	REL_STATUS_ENGAGED,
	REL_STATUS_MARRIED,
	REL_STATUS_SEPARATED,
	REL_STATUS_DIVORCED,
	REL_STATUS_WIDOWED
}

var first_name: String
var last_name: String
var display_picture_full_ref: String
var birthdate: int = 0
var relationship_status = REL_STATUS_NONE
var friend_count: int = 0
var is_friend = false


func _init(uid: String, json: Dictionary):
	super(uid, json)
	first_name = json.first_name
	last_name = json.get("last_name", "")
	display_picture_full_ref = json.get("display_picture_full", display_picture_ref)

	birthdate = int(json.get("birthdate", 0))
	relationship_status = int(json.get("relationship_status", REL_STATUS_NONE))
	friend_count = int(json.get("friend_count", 0))
	is_friend = bool(json.get("is_friend", is_friend))


func _get_name() -> String:
	return "%s %s" % [first_name, last_name]


func head_count_str() -> String:
	if friend_count > 0:
		return FbUtils.count_and_noun_tr(friend_count, "FB_MEMBER_HEAD_COUNT_FRIEND")
	return ""


func indicator_str() -> String:
	return "FB_MEMBER_IND_FRIENDS" if is_friend else ""


func relationship_status_str() -> String:
	match relationship_status:
		REL_STATUS_SINGLE:
			return "FB_MEMBER_REL_STAT_SINGLE"
		REL_STATUS_TAKEN:
			return "FB_MEMBER_REL_STAT_TAKEN"
		REL_STATUS_COMPLICATED:
			return "FB_MEMBER_REL_STAT_COMPLICATED"
		REL_STATUS_ENGAGED:
			return "FB_MEMBER_REL_STAT_ENGAGED"
		REL_STATUS_MARRIED:
			return "FB_MEMBER_REL_STAT_MARRIED"
		REL_STATUS_SEPARATED:
			return "FB_MEMBER_REL_STAT_SEPARATED"
		REL_STATUS_DIVORCED:
			return "FB_MEMBER_REL_STAT_DIVORCED"
		REL_STATUS_WIDOWED:
			return "FB_MEMBER_REL_STAT_WIDOWED"
		_:
			return "FB_MEMBER_REL_STAT_NONE"


func birthdate_str() -> String:
	var d = Time.get_datetime_dict_from_unix_time(birthdate)
	if Game.config.is_locale_non_latin():
		return "%d年%d月%d日" % [d.year, d.month, d.day]
	else:
		return "%s %d, %d" % [tr(Constants.MONTHS[d.month - 1]), d.day, d.year]
