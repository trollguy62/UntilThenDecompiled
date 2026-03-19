extends "../Screen.gd"

const FbMember = preload("res://data/fb/FbMember.gd")
const FbProfile = preload("res://data/fb/FbProfile.gd")
const FbPage = preload("res://data/fb/FbPage.gd")
const FbGroup = preload("res://data/fb/FbGroup.gd")

@onready var menu_bar = $MenuBar
@onready var cover_picture = $ScrollContainer/Main/Header/CoverPicture
@onready var profile_picture = $ScrollContainer/Main/Header/Member/DpContainer/ProfilePicture
@onready var name_label = $ScrollContainer/Main/Header/Member/NameContainer/Name
@onready var sub_name_label = $ScrollContainer/Main/Header/Member/NameContainer/Sub

@onready var description_label = $ScrollContainer/Main/About/Background/Main/Description
@onready var birthdate_row = $ScrollContainer/Main/About/Background/Main/Birthdate
@onready var birthdate_label = $ScrollContainer/Main/About/Background/Main/Birthdate/Label
@onready var rel_status_row = $ScrollContainer/Main/About/Background/Main/RelStatus
@onready var rel_status_label = $ScrollContainer/Main/About/Background/Main/RelStatus/Label
@onready var head_count_row = $ScrollContainer/Main/About/Background/Main/HeadCount
@onready var head_count_label = $ScrollContainer/Main/About/Background/Main/HeadCount/Label
@onready var indicator_row = $ScrollContainer/Main/About/Background/Main/Indicator
@onready var indicator_label = $ScrollContainer/Main/About/Background/Main/Indicator/Label

@onready var pictures_container = $ScrollContainer/Main/Pictures
@onready var picture_grid = $ScrollContainer/Main/Pictures/Background/Main/PictureGrid

var member: FbMember


func _ready():
	bg_color = Constants.COLOR_BG_FB

	menu_bar.title = member.name
	name_label.text = member.name

	cover_picture.picture = member.cover_picture_ref
	profile_picture.picture = member.display_picture_ref

	cover_picture.alt_load_delay = randf_range(0.3, 0.7)
	profile_picture.alt_load_delay = randf_range(0.3, 0.7)

	profile_picture.pressed.connect(_on_pressed_profile_picture_)

	if member is FbProfile:
		profile_picture.alt_picture = member.display_picture_full_ref

	sub_name_label.text = member.sub_name_str()
	sub_name_label.visible = not sub_name_label.text.is_empty()

	description_label.text = _description_text()
	description_label.visible = not description_label.text.is_empty()

	if member is FbProfile:
		birthdate_row.visible = member.birthdate > 0
		birthdate_label.text = member.birthdate_str()
	else:
		birthdate_row.visible = false

	if member is FbProfile:
		rel_status_row.visible = member.relationship_status != FbProfile.REL_STATUS_NONE
		rel_status_label.text = member.relationship_status_str()
	else:
		rel_status_row.visible = false

	head_count_label.text = member.head_count_str()
	head_count_row.visible = not head_count_label.text.is_empty()

	indicator_label.text = member.indicator_str()
	indicator_row.visible = not indicator_label.text.is_empty()

	pictures_container.visible = not member.picture_refs.is_empty()
	if pictures_container.visible:
		var entries = []
		for ref in member.picture_refs:
			entries.append({"picture_ref": ref, "alt_load_delay": randf_range(0.2, 0.6)})
		picture_grid.entries = entries


	menu_bar.hide_back_btn = false
	Story.emitted.connect(_on_story_emitted)
	Story.emit(member.uid)

func _before_show():
	menu_bar.disable_back_btn = true

func _after_show():
	menu_bar.disable_back_btn = false
	#FIXME: hack
	if menu_bar.hide_back_btn:
		profile_picture.btn.call_deferred("grab_focus")
	else:
		focus_on_enter.grab_focus()

func _before_hide():
	menu_bar.disable_back_btn = true

func _description_text() -> String:
	if member is FbPage or member is FbGroup:
		return member.description
	return ""

func _on_pressed_profile_picture_():
	Story.emit(member.uid + "_pp_showed")

func _on_story_emitted(name: String, value):
	match name:
		"hide_back_btn":
			menu_bar.hide_back_btn = value
			profile_picture.btn.call_deferred("grab_focus")

func _unhandled_input(event):
	if event.is_action_pressed("ui_down") and get_viewport().gui_get_focus_owner() == null:
		if not focus_on_enter.has_focus():
			focus_on_enter.call_deferred("grab_focus")
