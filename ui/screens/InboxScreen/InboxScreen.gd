extends "res://ui/screens/Screen.gd"

const Email = preload("res://data/Email.gd")
const InboxContent = preload("res://ui/screens/InboxScreen/InboxContent.tscn")

enum Mode { INBOX, DRAFTS }

@export var ids := []
@export var mode := Mode.INBOX

@onready var title_label = $MenuBar/Title
@onready var inbox_container = $ScrollContainer/InboxContainer
@onready var back_button = $MenuBar/BackButton

var _emails := []
var inbox := []
var id_index := 0
var draft_icon_color := Color(0.5, 0.5, 0.5, 1)


func _enter_tree():
	self.bg_color = Color(1, 1, 1, 0.75)


func _ready():
	title_label.text = ["EMAIL_INBOX_INBOX_TITLE", "EMAIL_INBOX_DRAFTS_TITLE"][mode]

	for id in ids:
		var email_json = Store.get_value("email://%s" % id)
		if email_json:
			var email = Email.new(email_json)
			_emails.append(email)
			_set_email(email)

func _before_hide():
	super._before_hide()
	back_button.disabled = true

func _after_show():
	super._after_show()
	back_button.disabled = false

func _set_email(email):
	var _content = InboxContent.instantiate()
	inbox_container.add_child(_content)
	inbox.append(_content)

	_content.select_email.connect(_on_email_click)
	_content.email = email
	_content.id = id_index
	_content.set_icon_color(_get_icon_color(email))

	id_index += 1


func _on_email_click(email_id):
	var navigator = Service.of(Service.NAVIGATOR)
	var _id = [ids[email_id]]
	navigator.push_named("email://sequence", {"ids": _id})


func _get_icon_color(email):
	if email.draft:
		return draft_icon_color
	else:
		return generate_random_color(email.sender_name)


func generate_random_color(_seed):
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(_seed)
	var red = rng.randf()
	var green = rng.randf()
	var blue = rng.randf()

	return Color(red, green, blue)
