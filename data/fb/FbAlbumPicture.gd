extends "FbAtom.gd"

const FbPicture = preload("res://data/fb/FbPicture.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")

var fb_picture: FbPicture
var picture_ref: String:
	get: return fb_picture.picture_ref


func _init(uid: String, json: Dictionary, parent: FbAtom):
	super(uid, json)
	fb_picture = FbPicture.new(json)
	likeable = parent.likeable
	shareable = false
	timestamp = parent.timestamp
	author_ref = parent.author_ref
