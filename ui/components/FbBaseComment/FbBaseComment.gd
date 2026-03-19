extends PanelContainer

const FbComment = preload("res://data/fb/FbComment.gd")
const FbMember = preload("res://data/fb/FbMember.gd")
const WebPageModel = preload("res://data/web/WebPageModel.gd")

const TextureRectButton = preload("res://ui/components/TextureRectButton/TextureRectButton.tscn")
const FbLink = preload("res://ui/components/FbLink/FbLink.tscn")

@onready var profile_picture = $Main/ProfilePicture
@onready var author_label = $Main/Content/Author
@onready var text_content = $Main/Content/Text
@onready var media_container = $Main/Content/Media
@onready var time_label = $Main/Content/Info/Time
@onready var like_btn = $Main/Content/Info/Anchor/Like
@onready var like_count_container = $Main/Content/Info/Likes
@onready var like_count_label = $Main/Content/Info/Likes/LikeCount
@onready var reply_btn = $Main/Content/Info/Reply

var comment: FbComment:
	set = _set_comment,
	get = _get_comment

var is_reply = false:
	set = _set_is_reply,
	get = _get_is_reply

var like_checker: DirtyChecker


func _ready():
	self.comment = comment
	self.is_reply = is_reply

	author_label.pressed.connect(_open_author)
	like_btn.pressed.connect(_toggle_liked)


func _open_author():
	var navigator = Service.of(Service.NAVIGATOR)
	navigator.push_named(comment.author_ref)


func _toggle_liked():
	comment.liked = not comment.liked

	if not comment.liked:
		return

	Game.savegame.save_liked_comment(comment.uid)
	var author = FbUtils.get_member(comment.author_ref)

	if author.uid == "MarkBorja":
		Game.dist_platform.unlock_achievement("ACH_SOCMED_LIKE_OWN_COMM_1")

	if Game.savegame.liked_comments.size() == 100:
		Game.dist_platform.unlock_achievement("ACH_SOCMED_LIKE_COMM_100")


func _set_comment(value):
	comment = value
	if profile_picture == null or comment == null:
		return

	var author = FbUtils.get_member(comment.author_ref)
	profile_picture.picture = author.display_picture_ref
	profile_picture.alt_route = comment.author_ref
	author_label.text = author.name
	text_content.text = comment.bbcode_content
	time_label.text = FbUtils.timestamp_str(comment.timestamp)

	if like_checker:
		like_checker.queue_free()

	like_checker = DirtyChecker.new(comment, "liked")
	like_checker.changed.connect(_update_like_stats)
	add_child(like_checker)

	_update_like_stats()
	_setup_media()


func _get_comment():
	return comment


func _set_is_reply(value):
	is_reply = value
	if profile_picture:
		profile_picture.custom_minimum_size = Vector2.ONE * (26 if is_reply else 32)


func _get_is_reply():
	return is_reply


func _update_like_stats():
	like_btn.visible = comment.likeable
	like_btn.text = "FB_BASE_COMMENT_UNLIKE" if comment.liked else "FB_BASE_COMMENT_LIKE"
	like_count_container.visible = comment.like_count > 0
	like_count_label.text = str(comment.like_count)


func _setup_media():
	media_container.size_flags_horizontal = SIZE_FILL
	media_container.visible = true

	if comment.picture_ref:
		var picture = load(comment.picture_ref)
		_setup_picture(picture)
		return

	var page = WebUtils.get_page_model(comment.link)
	if page:
		_setup_link(page)
		return

	media_container.visible = false


func _setup_picture(picture: Texture):
	var container = PanelContainer.new()
	var stylebox = StyleBoxFlat.new()
	stylebox.shadow_color = Color("#16000000")
	stylebox.shadow_size = 4
	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.add_theme_stylebox_override("panel", stylebox)
	media_container.add_child(container)

	var tex_rect = TextureRectButton.instantiate()
	container.add_child(tex_rect)
	await get_tree().process_frame

	var max_width = media_container.size.x
	var pic_size = picture.get_size()
	tex_rect.picture = picture
	tex_rect.alt_load_delay = randf_range(0.3, 0.9)

	if pic_size.x > max_width:
		tex_rect.fit_width = true
	else:
		tex_rect.custom_minimum_size = pic_size
		media_container.size_flags_horizontal = 0


func _setup_link(page: WebPageModel):
	var fb_link = FbLink.instantiate()
	fb_link.page = page
	fb_link.add_theme_constant_override("margin_left", 0)
	fb_link.add_theme_constant_override("margin_right", 0)
	media_container.add_child(fb_link)
