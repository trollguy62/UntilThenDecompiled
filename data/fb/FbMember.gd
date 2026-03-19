var uid: String:
	get: return uid
var name: String:
	get = _get_name
var display_picture_ref: String:
	get: return display_picture_ref
var cover_picture_ref: String:
	get: return cover_picture_ref
var picture_refs: Array = []:
	get: return picture_refs


func _init(uid: String, json: Dictionary):
	self.uid = uid
	name = json.get("name", "")
	display_picture_ref = json.get("display_picture", "assets/misc/display_picture.png")
	cover_picture_ref = json.get("cover_picture", "")

	for path in json.get("pictures", []):
		picture_refs.append(path)


func _get_name() -> String:
	return name


func head_count_str() -> String:
	return ""


func sub_name_str() -> String:
	return ""


func indicator_str() -> String:
	return ""
