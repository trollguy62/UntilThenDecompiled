extends VBoxContainer

const Email = preload("res://data/Email.gd")
const Attachment = preload("res://ui/screens/EmailScreen/Attachment.tscn")

@onready var subject = $Subject
@onready var info = $Info
@onready var spam = $Spam
@onready var body = $Body
@onready var attachments = $AttachmentsContainer/Attachments

var email: Email:
	set(value):
		email = value
		if email != null:
			_update()
	get:
		return email


func _update():
	var subject_text = email.subject.strip_edges()
	if email.draft:
		subject_text = "[color=#e81300]%s[/color] %s" % [tr("EMAIL_SUBJ_DRAFT"), subject_text]

	size.y = 0
	subject.text = subject_text
	var date_time = FbUtils.timestamp_str(email.timestamp)  # TODO own method
	info.text = "[b]%s[/b] (%s)\n%s" % [email.sender_name, email.sender_email, date_time]
	spam.visible = email.spam
	body.text = email.body

	attachments.visible = not email.attachments.is_empty()

	for child in attachments.get_children():
		child.queue_free()

	for attachment in email.attachments:
		assert(attachment is Dictionary)
		var view = Attachment.instantiate()
		view.file_name = attachment.get("name", "")
		view.file_size_bytes = attachment.get("size", 0)
		attachments.add_child(view)
