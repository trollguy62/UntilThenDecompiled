extends VBoxContainer
# TODO: Will make content overflow is username section gets wider
enum Vote { NEUTRAL = 0, UP = 1, DOWN = 2 }

const anonymous = "GEDDIT_USER_ANON"

@export var btn_neutral := Color("#747474")
@export var btn_active := Color("#ebb33c")

@onready var replies_container = $HBoxContainer/VBoxContainer/RepliesContainer
@onready var title_container = $TitleContainer
@onready var submitter_container = $HBoxContainer/VBoxContainer/SubmitterInfoContainer
@onready var userinfo_container = $HBoxContainer/VBoxContainer/UserInfoContainer
@onready var panel_container = $HBoxContainer/VBoxContainer/PanelContainer
@onready var actions_title = $TitleContainer/HBoxContainer/ActionsContainer_Title
@onready var actions = $HBoxContainer/ActionsContainer

@onready var spacer = $HBoxContainer/Spacer
@onready var submitted_by = $HBoxContainer/VBoxContainer/SubmitterInfoContainer/SubmittedBy
@onready var up_vote_root = $TitleContainer/HBoxContainer/ActionsContainer_Title/UpVoteRoot

@onready var title = $TitleContainer/HBoxContainer/Title
@onready var message = $HBoxContainer/VBoxContainer/PanelContainer/ContentContainer/Content/Message
@onready var username = $HBoxContainer/VBoxContainer/UserInfoContainer/Username
@onready var time = $HBoxContainer/VBoxContainer/UserInfoContainer/Time
@onready var up_vote = $HBoxContainer/VBoxContainer/UserInfoContainer/UpVote

@onready var btn_up = $HBoxContainer/ActionsContainer/BtnVoteUp
@onready var btn_down = $HBoxContainer/ActionsContainer/BtnVoteDown

var geddit_post  # res://ui/screens/GedditScreen/GedditPost.tscn
var content: Dictionary  # contains post info
var post_id: String  # current post id
var post_ids: Array = []  # collection of other post_ids associated to this post
var paths: Array = []  # collection of json paths associated to this post
var level = -1  # tree level

var _vote = Vote.NEUTRAL
var _up_vote = 1


func _ready():
	post_ids.append(post_id)

	_show_info()
	_add_replies()

	btn_up.pressed.connect(_on_btn_up_pressed.bind(btn_up))
	btn_down.pressed.connect(_on_btn_down_pressed.bind(btn_down))


func _show_info():
	message.text = content.message
	time.text = _get_time_posted(content.unix_time)

	if content.has("username"):
		username.text = content.username
	else:
		username.text = anonymous

	if content.has("title"):
		btn_up = $TitleContainer/HBoxContainer/ActionsContainer_Title/BtnVoteUp
		btn_down = $TitleContainer/HBoxContainer/ActionsContainer_Title/BtnVoteDown
		title_container.add_theme_constant_override("margin_bottom", 0)
		get_parent().add_theme_constant_override("margin_left", 10)

		title.text = content.title
		actions_title.show()
		spacer.show()
		submitter_container.show()
		submitted_by.text = tr("GEDDIT_SUBMITTED_BY") % [time.text, username.text]

		actions.hide()
		userinfo_container.hide()

	else:
		panel_container.set("theme_override_styles/panel", StyleBoxEmpty.new())
		title_container.hide()

	_up_vote = content.get("up_vote", 1)
	_vote = content.get("vote", Vote.NEUTRAL)

	_update_buttons()
	_update_up_vote_text()


# creates reply and its replies
func _add_replies():
	# if no more child/reply left, go back 1 level and check siblings
	if not _add_reply(post_ids):
		var post_ids_new = []
		var last_id = post_ids.back()

		if level == post_ids.size():
			post_ids.pop_back()
			level -= 1

		for i in range(level):
			post_ids_new.append(post_ids[i])

		post_ids_new.append(last_id)
		post_ids = post_ids_new

		_add_reply(post_ids_new)


# recursively add replies
func _add_reply(post_ids) -> bool:
	var path = _construct_path(post_ids)
	paths.append(path)

	level += 1

	# constructs post hierarchy
	var replies = Store.get_value(path)
	if replies:
		var index = 0

		for reply in replies.values():
			var post_container = geddit_post.instantiate()
			var post_id = replies.keys()[index]

			post_container.geddit_post = geddit_post
			post_container.content = reply
			post_container.post_id = post_id
			post_container.post_ids = post_ids
			post_container.paths = paths
			post_container.level = level

			post_container.size.x = size.x
			post_container.add_theme_constant_override("margin_left", 0)

			replies_container.add_child(post_container)

			index += 1

		return true

	return false  # no more child/reply left


func _construct_path(post_ids) -> String:
	var root = "geddit://posts/"
	var dir = "%s/replies/"
	var path = root

	# constructs path
	for i in range(post_ids.size()):
		path += dir % post_ids[i]

	# removes last '/' character
	path = path.substr(0, path.length() - 1)
	return path


func _get_time_posted(unix_time: int) -> String:
	var diff_sec = abs(Game.time - unix_time)

	if diff_sec >= 0 && diff_sec < 60:
		return tr("GEDDIT_TIME_JUST_NOW")
	elif diff_sec >= 60 && diff_sec < 3600:
		return tr("GEDDIT_TIME_MINS_AGO") % int(diff_sec / 60)
	elif diff_sec >= 3600 && diff_sec < 86400:
		return tr("GEDDIT_TIME_HOURS_AGO") % int(diff_sec / 3600)
	elif diff_sec >= 86400 && diff_sec < 2629743.83:
		return tr("GEDDIT_TIME_DAYS_AGO") % int(diff_sec / 86400)
	elif diff_sec >= 2629743.83 && diff_sec < 31556926:
		return tr("GEDDIT_TIME_MONTHS_AGO") % int(diff_sec / 2629743.83)
	elif diff_sec >= 31556926:
		return tr("GEDDIT_TIME_YEARS_AGO") % int(diff_sec / 31556926)

	# negative diff_sec (posted in the future)
	return "paradox"


func _make_vote(vote, btn: TextureButton):
	_vote = vote if _vote != vote else Vote.NEUTRAL
	content["vote"] = vote

	_update_buttons()
	_update_up_vote_text()


func _update_buttons():
	btn_down.modulate = btn_active if _vote == Vote.DOWN else btn_neutral
	btn_up.modulate = btn_active if _vote == Vote.UP else btn_neutral


func _update_up_vote_text():
	var points = _up_vote
	if _vote == Vote.UP:
		points += 1
	elif _vote == Vote.DOWN:
		points -= 1

	up_vote.text = _pluralize(points)
	up_vote_root.text = _wordize(points)


func _pluralize(count: int):
	if count == 1:
		return tr("GEDDIT_1_POINT")
	else:
		return tr("GEDDIT_N_POINTS") % _wordize(count)


func _wordize(count: int) -> String:
	var count_str = str(count)

	# medyo kadiri, but works
	match count_str.length():
		4:  # thousandth
			return "%s.%sk" % [count_str[0], count_str[1]]
		5:  # ten thousandth
			return "%s%s.%sk" % [count_str[0], count_str[1], count_str[2]]
		6:  # hundred thousandth
			return "%s%s%s.%sk" % [count_str[0], count_str[1], count_str[2], count_str[3]]
		7:  # millionth
			return "%s.%sM" % [count_str[0], count_str[1]]

	return str(count)


func _on_btn_up_pressed(btn: TextureButton):
	_make_vote(Vote.UP, btn)


func _on_btn_down_pressed(btn: TextureButton):
	_make_vote(Vote.DOWN, btn)
