extends "../Screen.gd"

const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbMember = preload("res://data/fb/FbMember.gd")
const FbAlbumPicture = preload("res://ui/screens/FbAlbumScreen/FbAlbumPicture.tscn")

@onready var scroll = $Scroll
@onready var main = $Scroll/Margin/Main

@onready var profile_picture = $Scroll/Margin/Main/Header/VBox/AuthorContainer/HBox/ProfilePicture
@onready var author_title = $Scroll/Margin/Main/Header/VBox/AuthorContainer/HBox/VBox/Title
@onready var author_subtitle = $Scroll/Margin/Main/Header/VBox/AuthorContainer/HBox/VBox/Subtitle
@onready var caption_container = $Scroll/Margin/Main/Header/VBox/CaptionContainer
@onready var caption_label = $Scroll/Margin/Main/Header/VBox/CaptionContainer/Label
@onready var stats_bar = $Scroll/Margin/Main/Header/VBox/FbAlbumStatsBar

var status: FbStatus
var scroll_to: int = -1

var _member: FbMember
var _scroll_to_view: Control


func _ready():
	assert(status.content_type == "album")

	self.bg_color = Constants.COLOR_BG_FB
	_member = FbUtils.get_member(status.author_ref)
	author_title.meta_clicked.connect(_on_link_clicked)

	profile_picture.picture = _member.display_picture_ref
	profile_picture.alt_route = status.author_ref
	author_title.text = FbUtils.get_status_author_title(status, _member.name)
	author_subtitle.text = FbUtils.get_status_author_subtitle(status)

	caption_container.visible = not status.caption.is_empty()
	caption_label.text = status.bbcode_caption

	stats_bar.atom = status
	_setup_pictures()


func _after_show():
	if scroll_to >= 0:
		var view = main.get_child(scroll_to + 1)
		scroll.scroll_to(view, Vector2(0, -8))
		scroll_to = -1  # Reset to prevent re-autoscroll


func _setup_pictures():
	if status.content.is_empty():
		return

	for album_pic in status.content:
		var view = FbAlbumPicture.instantiate()
		view.album_pic = album_pic
		main.add_child(view)

	main.add_child(Utils.make_empty_panel_container())


func _on_link_clicked(path):
	navigator.push_named(path)
