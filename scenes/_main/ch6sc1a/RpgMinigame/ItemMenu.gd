extends Control

signal item_selected(idx)

@onready var options = get_children()

var selected: int = -1


func _ready():
	item_selected.connect(_on_item_selected)


func _unhandled_input(event):
	if selected >= 0:
		return


func select(item_idx):
	get_tree().set_input_as_handled()
	selected = item_idx
	emit_signal("item_selected", item_idx)


func _on_item_selected(idx):
	for i in options.size():
		if i == idx:
			continue
		options[i].fade()
	await get_tree().create_timer(3.0)
	options[idx].fade()


func reset():
	for o in options:
		o.show()
		o.reset()
