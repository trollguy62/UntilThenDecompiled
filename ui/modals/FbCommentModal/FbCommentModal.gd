extends "../Modal.gd"

const FbAtom = preload("res://data/fb/FbAtom.gd")
const FbComment = preload("res://data/fb/FbComment.gd")

@onready var tween = Threen.new()
@onready var timer = $Timer
@onready var title_label = $VBox/Title
@onready var back_btn = $VBox/Title/BackButton

@onready var pager = $VBox/Pager
@onready var comments_container = $VBox/Pager/CommentsPage/Comments
@onready var no_comments_container = $VBox/Pager/CommentsPage/NoComments
@onready var comment_list = $VBox/Pager/CommentsPage/Comments/VBox/FbCommentList
@onready var replies_container = $VBox/Pager/RepliesPage/Scroll
@onready var reply_view = $VBox/Pager/RepliesPage/Scroll/VBox/FbComment
@onready var choice_box = $VBox/FbCommentChoiceBox
@onready var spinner = $Spinner

var atom: FbAtom


func _ready():
	self.cancelable = false
	add_child(tween)

	back_btn.pressed.connect(_on_back_btn_pressed)
	choice_box.chosen.connect(_on_choice_box_chosen)
	timer.timeout.connect(_setup)
	pager.tween_completed.connect(_on_pager_tween_completed)
	_enter()

	pager.modulate = Color.TRANSPARENT
	spinner.visible = true

	var setup_delay = 0.01
	if atom.comment_count > 0:
		setup_delay = randf_range(0.4, 1.2)
	timer.start(setup_delay)

func _process(delta):
	#FIXME: byproduct of spaghetti
	if _modal_handler != null:
		back_btn.disabled = not _modal_handler.is_modal_focused()


func dismiss():
	_exit()
	await Utils.wait(0.1)
	super.dismiss()


func _setup():
	_setup_comments()
	_show_comments()


func _setup_comments():
	var has_displayed_comments = atom.comment_count > 0
	comments_container.visible = has_displayed_comments
	no_comments_container.visible = not has_displayed_comments

	comment_list.open_replies_func = _show_replies
	comment_list.atom = atom


func _update_choices():
	var reply_shown = _get_reply_shown()
	var choose_func: Callable
	var choices = []

	if reply_shown:
		choices = reply_shown.choice_replies()
		choose_func = reply_shown.choose_reply
	else:
		choices = atom.choice_comments()
		choose_func = atom.choose_comment

	choice_box.choose_func = choose_func
	choice_box.choices = choices


func _show_comments():
	comments_container.show()
	pager.modulate = Color.WHITE
	spinner.visible = false

	title_label.text = "FB_COMMENTS_MODAL_TITLE"
	pager.page_index = 0
	_update_choices()


func _show_replies(comment: FbComment):
	replies_container.show()
	replies_container.size.y = 0
	replies_container.scroll_now_to(Vector2.ZERO)

	title_label.text = "FB_REPLIES_TITLE"
	reply_view.comment = comment
	pager.page_index = 1
	_update_choices()


func _is_comments_shown() -> bool:
	return pager.page_index == 0


func _get_reply_shown():
	if not _is_comments_shown():
		return reply_view.comment

func _on_pager_tween_completed():
	match pager.page_index:
		0:
			#hiding this makes it easier to focus controls when using the controller
			replies_container.hide()
			back_btn.grab_focus()
		1:
			#hiding this makes it easier to focus controls when using the controller
			comments_container.hide()
			back_btn.grab_focus()
		_:
			pass

func _on_back_btn_pressed():
	if back_btn.disabled:
		return

	if _is_comments_shown():
		dismiss()
	else:
		_show_comments()


func _on_choice_box_chosen(_idx: int):
	_update_choices()
	await get_tree().process_frame

	if no_comments_container.visible:
		_setup()
	if _is_comments_shown():
		comments_container.scroll_to_end()
	else:
		replies_container.scroll_to_end()


func _enter():
	visible = false
	await get_tree().process_frame

	var pos = [Vector2(0, size.y), Vector2.ZERO]
	tween.interpolate_property(
		self, "position", pos[0], pos[1], 0.3, Threen.TRANS_CUBIC, Threen.EASE_OUT
	)
	tween.start()
	visible = true

	tween.tween_all_completed.connect(func(): if focus_on_enter != null and Input.get_connected_joypads().size() > 0:\
										focus_on_enter.grab_focus())


func _exit():
	var pos = [Vector2.ZERO, Vector2(0, size.y)]
	tween.interpolate_property(
		self, "position", pos[0], pos[1], 0.3, Threen.TRANS_CUBIC, Threen.EASE_OUT
	)
	tween.start()


func _unhandled_input(event):
	if event.is_action_pressed("c_cancel") and is_visible_in_tree() \
			and _modal_handler and _modal_handler.is_modal_focused():
		_on_back_btn_pressed()
