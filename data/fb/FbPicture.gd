const FbPictureTag = preload("FbPictureTag.gd")

var tags: Array = []
var picture_ref: String
var picture: Texture:
	get:
		if picture == null:
			picture = load(picture_ref)
		return picture


func _init(json: Dictionary):
	for tag in json.get("tags", []):
		tags.append(FbPictureTag.new(tag))
	picture_ref = json.ref
