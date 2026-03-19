extends HBoxContainer

@export var title := "" :set = set_title
@export var names := "" :set = set_names

@onready var title_label = $Title
@onready var names_label = $Names


func _ready():
	self.title = title
	self.names = names


func set_title(value: String):
	title = value
	if is_inside_tree():
		title_label.text = title


func set_names(value: String):
	names = value
	if is_inside_tree():
		names_label.text = names
