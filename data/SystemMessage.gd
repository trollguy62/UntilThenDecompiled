extends "BaseMessage.gd"

const SENDER_KEY = "SYS"

const SystemMessage = preload("res://ui/components/SystemMessage/SystemMessage.tscn")


func _init(text: String, tags: Dictionary):
	super("sys", null, text, tags)


func get_control(conversation):
	var control = SystemMessage.instantiate()
	control.get_node("Label").text = content
	return control


func is_grouped_with(other):
	return false


func preview_str(conversation) -> String:
	return content
