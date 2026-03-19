extends Panel

const FbQuark = preload("res://data/fb/FbQuark.gd")
const FbAtom = preload("res://data/fb/FbAtom.gd")

@onready var tween = Threen.new()
@onready var like_btn = $Main/LikeBtn
@onready var comment_btn = $Main/CommentBtn
@onready var stats_container = $Main/Stats
@onready var likes_label = $Main/Stats/Likes
@onready var comments_label = $Main/Stats/Comments

var atom: FbAtom:
	set = _set_atom,
	get = _get_atom

var _like_checker: DirtyChecker


func _ready():
	add_child(tween)
	comment_btn.pressed.connect(_show_comment_modal)
	stats_container.pressed.connect(_show_comment_modal)


func _set_atom(value):
	if atom:
		atom.comments_changed.disconnect(_update_stats)

	atom = value

	if _like_checker:
		_like_checker.queue_free()
	if atom == null:
		return

	_like_checker = DirtyChecker.new(atom, "liked")
	_like_checker.changed.connect(_update_stats)
	add_child(_like_checker)

	atom.comments_changed.connect(_update_stats)

	if like_btn:
		like_btn.atom = atom
		_update_stats()


func _get_atom():
	return atom


func _update_stats():
	if likes_label == null:
		return

	var comment_count = atom.comment_count
	like_btn.visible = atom.likeable

	likes_label.visible = atom.like_count > 0
	comments_label.visible = comment_count > 0

	likes_label.text = FbUtils.count_and_noun_tr(atom.like_count, "FB_STATSBAR_LIKE")
	comments_label.text = FbUtils.count_and_noun_tr(comment_count, "FB_STATSBAR_COMMENT")


func _show_comment_modal():
	FbUtils.reveal_comment_modal(atom)
