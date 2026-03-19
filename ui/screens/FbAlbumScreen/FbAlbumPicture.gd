extends PanelContainer

const FbAlbumPicture = preload("res://data/fb/FbAlbumPicture.gd")

@onready var picture_view = $Main/Picture
@onready var caption_container = $Main/CaptionContainer
@onready var caption_label = $Main/CaptionContainer/Label
@onready var stats_bar = $Main/FbAlbumStatsBar

var album_pic: FbAlbumPicture


func _ready():
	picture_view.picture = album_pic.picture_ref
	picture_view.alt_route = "fb://picture"
	picture_view.alt_route_payload = {"atom": album_pic}

	caption_container.visible = not album_pic.caption.is_empty()
	caption_label.text = album_pic.bbcode_caption
	stats_bar.atom = album_pic
