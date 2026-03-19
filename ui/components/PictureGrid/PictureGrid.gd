extends HBoxContainer

const TextureRectButton = preload("res://ui/components/TextureRectButton/TextureRectButton.tscn")

@onready var col1 = $Col1
@onready var col2 = $Col2

var entries: Array = []:
	set(value):
		entries = value
		_update()
	get:
		return entries


func _ready():
	_update()


func _update():
	if col1 == null:
		return

	var count = entries.size()
	custom_minimum_size.y = (1 + ceil(count / 2.0)) * 100
	col2.visible = count > 1

	for i in range(count):
		var entry = entries[i]
		var btn = TextureRectButton.instantiate()
		var col = col1 if i % 2 == 0 else col2

		btn.picture = entry.picture_ref
		btn.load_delay = entry.get("load_delay", 0.0)
		btn.alt_route = entry.get("alt_route", "")
		btn.alt_route_payload = entry.get("alt_route_payload", {})
		btn.alt_load_delay = entry.get("alt_load_delay", 0.0)

		btn.size_flags_horizontal = SIZE_EXPAND_FILL
		btn.size_flags_vertical = SIZE_EXPAND_FILL
		col.add_child(btn)
