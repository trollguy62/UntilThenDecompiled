extends Control

const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbMember = preload("res://data/fb/FbMember.gd")

@onready var main_vbox = $Panel/Main
@onready var click_rect = $Panel/ClickRect

@onready var profile_picture = $Panel/Main/AuthorContainer/HBox/ProfilePicture
@onready var author_title = $Panel/Main/AuthorContainer/HBox/VBox/Title
@onready var author_subtitle = $Panel/Main/AuthorContainer/HBox/VBox/Subtitle

@onready var caption_container = $Panel/Main/CaptionContainer
@onready var caption_label = $Panel/Main/CaptionContainer/Label

@onready var content_container = $Panel/Main/ContentContainer

var status: FbStatus
var _member: FbMember


func _ready():
	_member = FbUtils.get_member(status.author_ref)

	click_rect.pressed.connect(_open_full_status)

	profile_picture.picture = _member.display_picture_ref
	author_title.text = FbUtils.get_status_author_title(status, _member.name)
	author_subtitle.text = FbUtils.get_status_author_subtitle(status, false)

	caption_container.visible = not status.caption.is_empty()
	caption_label.text = status.bbcode_caption

	_setup_content()

	if not content_container.visible:
		var sep = main_vbox.get_theme_constant("separation")
		caption_container.add_theme_constant_override("margin_bottom", sep)


func _setup_content():
	var content_view = FbUtils.make_content_view(status)
	if content_view:
		content_container.visible = true
		content_container.add_child(content_view)


func _open_full_status():
	var navigator = Service.of(Service.NAVIGATOR)
	navigator.push_named("fb://posts/" + status.uid)
