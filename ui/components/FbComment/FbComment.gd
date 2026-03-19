extends VBoxContainer

const FbComment = preload("res://data/fb/FbComment.gd")
const FbMember = preload("res://data/fb/FbMember.gd")
const FbBaseComment = preload("res://ui/components/FbBaseComment/FbBaseComment.tscn")

@export var expand_replies = false:
	set = _set_expand_replies,
	get = _get_expand_replies

@onready var root_comment = $RootComment
@onready var replies_container = $Replies
@onready var collapsed_replies = $Replies/Collapsed
@onready var expanded_replies = $Replies/Expanded

@onready var collapsed_replies_btn = $Replies/Collapsed
@onready var collapsed_reply_profile_picture = $Replies/Collapsed/Margin/HBox/ProfilePicture
@onready var collapsed_reply_author_label = $Replies/Collapsed/Margin/HBox/Author
@onready var collapsed_reply_count_label = $Replies/Collapsed/Margin/HBox/ReplyCount

var comment: FbComment:
	set = _set_comment,
	get = _get_comment

var open_replies_func: Callable = _open_replies_screen  # (FbComment) -> ()


func _ready():
	self.comment = comment
	self.expand_replies = expand_replies
	collapsed_replies_btn.pressed.connect(_open_replies)


func _set_comment(value):
	if comment != null and comment.replies_changed.is_connected(_update_replies):
		comment.replies_changed.disconnect(_update_replies)

	comment = value

	if root_comment and comment:
		root_comment.comment = comment
		_clear_expanded_replies()
		_update_replies()
		comment.replies_changed.connect(_update_replies)


func _get_comment():
	return comment


func _set_expand_replies(value):
	expand_replies = value
	if root_comment and comment:
		_update_replies()


func _get_expand_replies():
	return expand_replies


func _open_replies():
	open_replies_func.call(comment)


func _open_replies_screen(comment: FbComment):
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator and comment:
		navigator.push_named("fb://comment", {"comment": comment})


func _update_replies():
	var ordered_replies = comment.ordered_replies()
	replies_container.visible = not ordered_replies.is_empty()
	if not replies_container.visible:
		return

	collapsed_replies.visible = not expand_replies
	expanded_replies.visible = expand_replies

	if expand_replies:
		_update_expanded_replies(ordered_replies)
	else:
		_clear_expanded_replies()
		_update_collapsed_replies(ordered_replies)


func _update_collapsed_replies(ordered_replies: Array):
	var last_reply = ordered_replies.back()
	var last_reply_author = FbUtils.get_member(last_reply.author_ref)
	var count_text = FbUtils.count_and_noun_tr(comment.reply_count, "FB_COMMENT_REPLY")

	collapsed_reply_profile_picture.picture = last_reply_author.display_picture_ref
	collapsed_reply_author_label.text = last_reply_author.name
	collapsed_reply_count_label.text = count_text


func _update_expanded_replies(ordered_replies: Array):
	for i in range(ordered_replies.size()):
		var reply: FbComment = ordered_replies[i]
		if expanded_replies.has_node(reply.uid):
			continue

		var view = FbBaseComment.instantiate()
		view.name = reply.uid
		view.comment = reply
		view.is_reply = true

		expanded_replies.add_child(view)
		expanded_replies.move_child(view, i)


func _clear_expanded_replies():
	for reply in expanded_replies.get_children():
		expanded_replies.remove_child(reply)
		reply.queue_free()


func get_reply_view(uid: String):
	if comment.replies.has(uid):
		return expanded_replies.get_node(uid)
