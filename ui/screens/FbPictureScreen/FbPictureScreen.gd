extends "../Screen.gd"

const FbPicture = preload("res://data/fb/FbPicture.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")
const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbAlbumPicture = preload("res://data/fb/FbAlbumPicture.gd")
const FbPictureTag = preload("res://ui/screens/FbPictureScreen/FbPictureTag.tscn")

@onready var picture_component = $PictureComponent
@onready var stats_bar = $FbMediaStatsBar
#@onready var tags_container = $PictureScreen/TextureRect/Tags
@onready var menu_bar = $MenuBar

var atom: FbAtom


func _ready():
	var fb_picture: FbPicture

	if atom is FbAlbumPicture:
		fb_picture = atom.fb_picture
	elif atom is FbStatus and atom.content is FbPicture:
		fb_picture = atom.content

	var pic_ref = fb_picture.picture_ref
	var image = load(pic_ref)

	var args = [fb_picture.tags, image.get_size()]
	picture_component.loaded_picture.connect(_place_tags.bindv(args))

	picture_component.picture = image
	stats_bar.atom = atom
	menu_bar.disable_back_btn = true

func _after_show():
	super._after_show()
	menu_bar.disable_back_btn = false

func _before_hide():
	super._before_hide()
	menu_bar.disable_back_btn = true

func _place_tags(tags: Array, image_size: Vector2):
	# TODO: Rendered defunct by PictureComponent. Restore.
	pass
#	var parent_offset = picture_component.get_picture_pos()
#	var parent_size = picture_component.get_picture_size()
#
#	for tag in tags:
#		var tag_view = FbPictureTag.instantiate()
#		tag_view.tag = tag
#		tag_view.parent_offset = parent_offset
#		tag_view.parent_size = parent_size
#		tag_view.image_size = image_size
#		tag_view.reposition()
#		tags_container.add_child(tag_view)
