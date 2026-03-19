const WebLink = preload("res://data/web/WebLink.gd")

var link: WebLink:
	get: return link
var title: String:
	get: return title
var description: String:
	get: return description
var icon_ref: String:
	get: return icon_ref
var display_ref: String:
	get: return display_ref


func _init(link: WebLink, dict: Dictionary):
	self.link = link
	title = dict.title
	description = dict.get("description", "")
	icon_ref = dict.get("icon", "")
	display_ref = dict.get("display", "")
