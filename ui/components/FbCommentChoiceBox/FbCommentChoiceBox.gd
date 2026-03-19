extends PanelContainer

signal chosen(idx)

const FbComment = preload("res://data/fb/FbComment.gd")
const ChoiceListItem = preload("res://ui/screens/ChatScreen/ChoiceListItem.tscn")

@onready var list = $Margin/Main

var choices: Array:
	set = _set_choices,
	get = _get_choices

var choose_func: Callable


func _ready():
	visible = false


func _set_choices(value):
	choices = value

	for child in list.get_children():
		child.queue_free()

	for i in range(choices.size()):
		var comment: FbComment = choices[i]
		assert(comment.is_choice())

		var text = comment.choice_preview()
		var btn = _make_choice_list_item(text, i)
		btn.pressed.connect(_on_pressed_choice.bind(i))
		list.add_child(btn)

	visible = not choices.is_empty()
	if visible:
		await get_tree().process_frame
		size.y = 0  # update height


func _get_choices():
	return choices


func _on_pressed_choice(idx: int):
	if choose_func:
		var uid = choices[idx].uid
		choose_func.call(uid)

	self.choices = []
	chosen.emit(idx)


func _make_choice_list_item(text: String, idx: int = 0) -> Control:
	var btn = ChoiceListItem.instantiate()
	btn.text = text
	btn.idx = idx
#	btn.bg_color = Color.BLACK
	btn.text_color = Color.BLACK
	return btn
