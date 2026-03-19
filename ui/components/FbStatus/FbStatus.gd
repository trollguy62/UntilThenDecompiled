extends PanelContainer

const FbQuark = preload("res://data/fb/FbQuark.gd")
const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbMember = preload("res://data/fb/FbMember.gd")

const COLLAPSED_MAX_LINES = 8

@onready var tween = Threen.new()
@onready var main_vbox = $Main

@onready var meta_container = $Main/MetaContainer
@onready var meta_label = $Main/MetaContainer/Margin/Meta

@onready var author_container = $Main/AuthorContainer
@onready var profile_picture = $Main/AuthorContainer/HBox/ProfilePicture
@onready var author_title = $Main/AuthorContainer/HBox/VBox/Title
@onready var author_subtitle = $Main/AuthorContainer/HBox/VBox/Subtitle

@onready var caption_container = $Main/CaptionContainer
@onready var caption_label = $Main/CaptionContainer/Label

@onready var read_more_container = $Main/ReadMoreContainer
@onready var read_more_label = $Main/ReadMoreContainer/Label/Button

@onready var content_container = $Main/ContentContainer

@onready var stats_container = $Main/StatsContainer
@onready var likes_label = $Main/StatsContainer/Stats/Likes
@onready var comments_label = $Main/StatsContainer/Stats/Comments
@onready var shares_label = $Main/StatsContainer/Stats/Shares
@onready var stats_btn = $Main/StatsContainer/StatsBtn

@onready var actions_margin = $Main/ActionsContainer
@onready var action_like = $Main/ActionsContainer/MarginContainer/Main/LikeButton
@onready var action_comment = $Main/ActionsContainer/MarginContainer/Main/CommentButton
@onready var action_share = $Main/ActionsContainer/MarginContainer/Main/ShareButton

@onready var comment_container = $Main/CommentsContainer
@onready var comment_list = $Main/CommentsContainer/FbCommentList

# This is first (if not exclusively) used in Lo1Sc6
@onready var caption_visible_notifier = $Main/CaptionContainer/VisibleOnScreenNotifier2D

@export var max_comments = 0
@export var hide_meta = false
@export var expand_caption = false

var status: FbStatus
var _member: FbMember


func _ready():
	add_child(tween)

	_member = FbUtils.get_member(status.author_ref)

	author_title.meta_clicked.connect(_on_link_clicked)
	meta_label.meta_clicked.connect(_on_link_clicked)
	stats_btn.pressed.connect(_show_comment_modal)
	action_comment.pressed.connect(_show_comment_modal)
	read_more_label.pressed.connect(_on_read_more_pressed)
	status.comments_changed.connect(_update_stats)
	action_share.pressed.connect(_on_action_share_pressed)

	profile_picture.picture = _member.display_picture_ref
	profile_picture.alt_route = status.author_ref
	author_title.text = FbUtils.get_status_author_title(status, _member.name)
	author_subtitle.text = FbUtils.get_status_author_subtitle(status)

	caption_visible_notifier.screen_entered.connect(_on_caption_screen_entered)

	_update_stats()
	action_like.atom = status
	action_share.atom = status
	comment_list.max_comments = max_comments
	comment_list.atom = status

	_setup_meta()
	_setup_caption()
	_setup_content()
	_setup_checkers()

	await get_tree().process_frame
	size.y = 0


func _update_stats():
	_set_stats_of(likes_label, status.like_count, "FB_STATUS_STAT_LIKE")
	_set_stats_of(comments_label, status.comment_count, "FB_STATUS_STAT_COMMENT")
	_set_stats_of(shares_label, status.share_count, "FB_STATUS_STAT_SHARE")
	stats_container.visible = likes_label.visible or comments_label.visible or shares_label.visible

	action_like.visible = status.likeable
	action_share.visible = status.shareable
	actions_margin.visible = action_like.visible or action_comment.visible or action_share.visible
	comment_container.visible = _is_comments_shown()


func _set_stats_of(label: Label, count: int, message_prefix: String):
	label.visible = count > 0
	label.text = FbUtils.count_and_noun_tr(count, message_prefix)


func _is_comments_shown():
	return max_comments != 0 and status.comment_count > 0


func _setup_meta():
	meta_container.visible = not hide_meta and not status.meta.is_empty()

	if not meta_container.visible:
		var sep = main_vbox.get_theme_constant("separation")
		author_container.add_theme_constant_override("margin_top", sep)
	else:
		meta_label.text = FbUtils.transform_bbcode_text(status.meta)


func _setup_caption():
	if status.caption.is_empty():
		caption_container.visible = false
		read_more_container.visible = false
		return

	caption_label.text = status.bbcode_caption

	if expand_caption:
		caption_label.max_lines_visible = -1
		read_more_container.visible = false
	else:
		caption_label.max_lines_visible = COLLAPSED_MAX_LINES
		await get_tree().process_frame
		read_more_container.visible = not caption_label.is_completely_visible()


func _setup_content():
	var content_view = FbUtils.make_content_view(status)
	if content_view:
		content_container.visible = true
		content_container.add_child(content_view)


func _setup_checkers():
	var props = ["liked", "shared"]
	for prop in props:
		var checker = DirtyChecker.new(status, prop)
		checker.changed.connect(_update_stats)
		add_child(checker)


func _on_link_clicked(path):
	Service.of(Service.NAVIGATOR).push_named(path)


func _on_read_more_pressed():
	Service.of(Service.NAVIGATOR).push_named("fb://posts/" + status.uid)


func _on_caption_screen_entered():
	Story.emit(status.uid + "_caption_screen_entered")


func _show_comment_modal():
	if not _is_comments_shown():
		FbUtils.reveal_comment_modal(status)


func _on_action_share_pressed():
	if not action_share.atom.shared:
		return

	Game.savegame.save_shared_post(status.uid)
	if Game.savegame.shared_posts.size() == 10:
		Game.dist_platform.unlock_achievement("ACH_SOCMED_SHARE_POST_10")


func get_comment_view(uid: String):
	if status.comments.has(uid):
		return comment_list.get_comment_view(uid)
