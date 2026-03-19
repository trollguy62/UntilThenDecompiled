const FbMember = preload("FbMember.gd")

const COLOR_STAT_INACTIVE = Color("#9e9ba3")
const COLOR_STAT_ACTIVE = Color("#8b62de")

var _dict: Dictionary

var uid: String
var author_ref: String
var likeable: bool

var timestamp: int:
	set(value): _dict.timestamp = value
	get: return int(_dict.get("timestamp", 0))

var like_count: int:
	get: return like_count + (1 if self.liked else 0)

var liked: bool:
	set(value): _dict.liked = value
	get: return bool(_dict.get("liked", false))


func _init(uid: String, json: Dictionary):
	self.uid = uid
	self._dict = json

	author_ref = json.get("author_ref", "fb://pages/godot")
	like_count = int(json.get("like_count", 0))
	likeable = bool(json.get("likeable", true))
