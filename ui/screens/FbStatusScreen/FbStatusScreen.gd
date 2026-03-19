extends "../Screen.gd"

const FbStatus = preload("res://data/fb/FbStatus.gd")
const FbStatusView = preload("res://ui/components/FbStatus/FbStatus.tscn")

@onready var scroll = $VBox/Scroll
@onready var status_container = $VBox/Scroll/Margin
@onready var choice_box = $VBox/FbCommentChoiceBox
@onready var status_view = FbStatusView.instantiate()
@onready var menu_bar = $MenuBar
var status: FbStatus
var scroll_to_comment_uid: String = ""


func _ready():
	self.bg_color = Constants.COLOR_BG_FB

	choice_box.choose_func = status.choose_comment
	choice_box.chosen.connect(_on_choice_box_chosen)

	status_view.status = status
	status_view.max_comments = -1
	status_view.hide_meta = true
	status_view.expand_caption = true
	status_container.add_child(status_view)


func _before_show():
	_update_choices()
	menu_bar.disable_back_btn = true


func _after_show():
	_scroll_to_comment()
	menu_bar.disable_back_btn = false

func _before_hide():
	menu_bar.disable_back_btn = true


func _scroll_to_comment():
	var comment_view = status_view.get_comment_view(scroll_to_comment_uid)
	if comment_view:
		scroll.scroll_to(comment_view, Vector2(0, -8))
		scroll_to_comment_uid = ""  # Reset to prevent re-autoscroll


func _update_choices():
	choice_box.choices = status.choice_comments()


func _on_choice_box_chosen(_i: int):
	await get_tree().process_frame
	scroll.scroll_to_end()

func _unhandled_input(event):
	if event.is_action_pressed("d_up"):
		$MenuBar/BackButton.call_deferred("grab_focus")
