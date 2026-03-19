extends "../Screen.gd"

const FbComment = preload("res://data/fb/FbComment.gd")

@onready var scroll = $VBox/Scroll
@onready var comment_view = $VBox/Scroll/Margin/Main/FbComment
@onready var choice_box = $VBox/FbCommentChoiceBox

var comment: FbComment:
	set = _set_comment,
	get = _get_comment

var scroll_to_reply_uid: String = ""


func _ready():
	self.bg_color = Constants.COLOR_BG_FB
	self.comment = comment

	choice_box.chosen.connect(_on_choice_box_chosen)


func _before_show():
	_update_choices()


func _after_show():
	_scroll_to_reply()


func _scroll_to_reply():
	var reply_view = comment_view.get_reply_view(scroll_to_reply_uid)
	if reply_view:
		scroll.scroll_to(reply_view, Vector2(0, -8))
		scroll_to_reply_uid = ""  # Reset to prevent re-autoscroll


func _set_comment(value):
	comment = value
	if comment_view:
		comment_view.comment = comment
		choice_box.choose_func = comment.choose_reply
		_update_choices()


func _get_comment():
	return comment


func _update_choices():
	if comment:
		choice_box.choices = comment.choice_replies()


func _on_choice_box_chosen(_i: int):
	await get_tree().process_frame
	scroll.scroll_to_end()
