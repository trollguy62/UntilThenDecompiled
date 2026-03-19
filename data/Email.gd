var subject: String
var sender_name: String
var sender_email: String
var timestamp: int
var spam: bool
var body: String
var draft: bool
var attachments: Array


func _init(json: Dictionary):
	subject = json.get("subject", "")
	sender_name = json.get("sender_name", "")
	sender_email = json.get("sender_email", "")
	timestamp = json.get("timestamp", 0)
	spam = json.get("spam", false)
	body = json.get("body", "")
	draft = json.get("draft", false)
	attachments = json.get("attachments", [])
