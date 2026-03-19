extends RichTextLabel


func _ready():
	draw.connect(_on_draw)


func _on_draw():

	custom_minimum_size.y = get_v_scroll_bar().max_value
	get_parent().size = Vector2.ZERO
