const FbProfile = preload("res://data/fb/FbProfile.gd")

signal online_changed
signal conversation_focus_changed

const DEFAULT_TYPING_SPEED = 20.0

var first_name: String
var last_name: String
var full_name: String:
	get:
		if last_name == "":
			return first_name
		elif first_name == "":
			return last_name
		
		var sep = "·" if Game.config.is_locale_non_latin() else " "
		return first_name + sep + last_name

var typing_speed: float

var profile_picture: Texture:
	get:
		return load(self.fb_profile.display_picture_full_ref)

var fb_profile: FbProfile:
	get:
		var json = Store.get_value("fb://profiles/" + self.fb_profile_uid)
		return FbProfile.new(self.fb_profile_uid, json)

var fb_profile_uid: String:
	get:
		# Amazing hardcoded hack
		# Ridel has two profile variations. We use the other one if we're in Pt2.
		if fb_profile_uid == "RidelGonzales" and Game.playthrough == 2:
			return "dufhh0q8ze6"
		return fb_profile_uid

var _json: Dictionary

var online: bool = false:
	set(value):
		if online != value:
			online = value
			online_changed.emit()
	get:
		return online

var conversation_focus:
	set(value):
		if conversation_focus != value:
			conversation_focus = value
			conversation_focus_changed.emit()
	get:
		return conversation_focus


func _init(json: Dictionary):
	self._json = json
	first_name = json.first_name
	last_name = json.last_name
	typing_speed = json.get("typing_speed", DEFAULT_TYPING_SPEED)
	fb_profile_uid = json.fb_profile_uid


func get_prop(key: String, default):
	return _json.get(key, default)


func is_focused_on(conversation):
	return online and conversation_focus == conversation


func focus_on(conversation):
	self.online = true
	self.conversation_focus = conversation
