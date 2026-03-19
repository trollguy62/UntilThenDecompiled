extends "Choice.gd"

const ChoiceTextField = preload("res://ui/screens/ChatScreen/ChoiceTextField.gd")

var choice_text_field: ChoiceTextField
var text: String


func _init(choice_text_field: ChoiceTextField, name: String, text: String = ""):
	super(name)
	self.choice_text_field = choice_text_field
	self.text = text


func enter():
	super.enter()
	var msg = name if text == "" else text
	choice_text_field.text_message = msg
