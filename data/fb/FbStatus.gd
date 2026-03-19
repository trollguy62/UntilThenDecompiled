extends "FbAtom.gd"

const FbPicture = preload("FbPicture.gd")
const FbAlbumPicture = preload("FbAlbumPicture.gd")

const CONTENT_TYPE_PICTURE = "picture"
const CONTENT_TYPE_ALBUM = "album"
const CONTENT_TYPE_VIDEO = "video"
const CONTENT_TYPE_LINK = "link"
const CONTENT_TYPE_SHARE = "share"

var meta: String = ""
var action: String = ""
var content_type: String = "none"
var content
var sponsored = false


func _init(uid: String, json: Dictionary):
	super(uid, json)
	meta = json.get("meta", meta)
	action = json.get("action", action)
	content_type = json.get("content_type", content_type)
	sponsored = bool(json.get("sponsored", sponsored))

	_parse_content(json)


func _parse_content(json):
	match content_type:
		CONTENT_TYPE_PICTURE:
			content = FbPicture.new(json.picture)

		CONTENT_TYPE_ALBUM:
			content = []
			for i in range(json.album.size()):
				var uid = str(i)
				var pic_json = json.album[i]
				content.append(FbAlbumPicture.new(uid, pic_json, self))

		CONTENT_TYPE_VIDEO:
			content = json.video_ref

		CONTENT_TYPE_LINK:
			content = {"page": WebUtils.get_page_model(json.link), "cta": json.get("cta", "")}

		CONTENT_TYPE_SHARE:
			content = json.share_uid
