extends Button

signal select_email(id)

const Email = preload("res://data/Email.gd")

@onready var sender_icon = $HBoxContainer/SenderIcon
@onready var sender_icon_label = $HBoxContainer/SenderIcon/IconLabel
@onready var email_icon = $HBoxContainer/SenderIcon/EmailIcon
@onready var sender = $HBoxContainer/VBoxContainer/HBoxContainer/Sender
@onready var date = $HBoxContainer/VBoxContainer/HBoxContainer/Date
@onready var subject = $HBoxContainer/VBoxContainer/Subject
@onready var body = $HBoxContainer/VBoxContainer/Body

var email: Email:
	set(value):
		email = value
		if email != null:
			_update()
	get:
		return email

var id: int
var draft_font_color := Color(0.91, 0.07, 0, 1)


func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)


func _update():
	subject.text = email.subject
	var date_time = FbUtils.timestamp_str(email.timestamp)
	date.text = date_time
	body.text = strip_bbcode(email.body)
	sender_icon_label.text = email.sender_name.left(1)
	set_email_type(email)


func set_icon_color(color):
	sender_icon.self_modulate = color


func _on_pressed():
	select_email.emit(id)

func _on_mouse_entered():
	grab_focus()

func set_email_type(email):
	if email.draft:
		sender.text = "EMAIL_INBOX_DRAFT_TITLE"
		sender.add_theme_color_override("font_color", draft_font_color)
		email_icon.visible = true
		sender_icon_label.visible = false
	else:
		sender.text = email.sender_name
		sender.add_theme_color_override("font_color", Color.BLACK)
		email_icon.visible = false
		sender_icon_label.visible = true


func strip_bbcode(source: String) -> String:
	var regex = RegEx.new()
	regex.compile("(\\[.+?\\])|(res:.+?\\....)|(\\n+)")
	return regex.sub(source, "", true)
