extends VBoxContainer

signal choice_pressed

const KEY_MAP = ["choice_1", "choice_2", "choice_3", "choice_4"]
const TOP_MARGIN = 16.0

const ChoiceListItem = preload("res://ui/screens/ChatScreen/ChoiceListItem.tscn")

@export var show_top_margin = false

@onready var top_margin = PanelContainer.new()

var _choices := []
var choices: Array:
	set = set_choices,
	get = get_choices

var _choice_list_items = []


func _ready():
	top_margin.set("theme_override_styles/panel", StyleBoxEmpty.new())
	add_child(top_margin)


func _process(delta):
	top_margin.visible = show_top_margin

	if show_top_margin:
		var separation = get("theme_override_constants/separation")
		top_margin.custom_minimum_size = Vector2(0, TOP_MARGIN - separation)


func set_choices(value):
	clear_choices()
	_choices = value

	for i in range(_choices.size()):
		var item = ChoiceListItem.instantiate()
		item.idx = i
		item.text = _choices[i].name

		add_child(item)
		_choice_list_items.append(item)
		item.pressed.connect(_on_choice_pressed.bind(i))


func get_choices():
	return _choices


func clear_choices():
	for item in _choice_list_items:
		item.queue_free()

	_choices = []
	_choice_list_items = []


func _on_choice_pressed(idx):
	choice_pressed.emit(idx)
