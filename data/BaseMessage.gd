const Character = preload("Character.gd")

var type = "none"
var sender: Character
var content
var tags: Dictionary

enum { GROUP_SINGLE, GROUP_START, GROUP_MIDDLE, GROUP_END }


func _init(type: String, sender: Character, content, tags: Dictionary):
	self.type = type
	self.sender = sender
	self.content = content
	self.tags = tags


func get_control(conversation):
	var label = Label.new()
	label.text = "BaseMessage"
	return label


func is_grouped_with(other):
	return sender == other.sender


func is_from_player(conversation):
	return sender == conversation.player


func preview_str(conversation) -> String:
	return str(content)
