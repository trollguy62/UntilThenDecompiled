extends Container

const CreditLine = preload("res://scenes/_main/ch5sc11/assets/prefabs/CreditLine.tscn")

@export var loop_infinite = false
@export_multiline var credits : Array[String]

@onready var credit_lines = $MarginContainer/CreditLines


func _ready():
	_clear_credit_lines()


func start():
	if loop_infinite:
		while is_inside_tree():
			await _roll()
	else:
		await _roll()


func _clear_credit_lines():
	for child in credit_lines.get_children():
		child.queue_free()


func _roll():
	_clear_credit_lines()

	for raw in credits:
		var lines = raw.split("\n")
		var credit_line_view = CreditLine.instantiate()

		for line in lines:
			var split_idx = line.find("|")
			var title = line.substr(0, split_idx)
			var delim: String = "\n"
			var names = line.substr(split_idx + 1).split(",")
			names = delim.join(names)

			credit_line_view.title = title
			credit_line_view.names = names
			credit_lines.add_child(credit_line_view)

		await Utils.wait(3.25)
		_clear_credit_lines()
		await Utils.wait(0.75)
