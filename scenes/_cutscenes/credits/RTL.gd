extends RichTextLabel

var custom_min_width = 0

func _ready():
	custom_minimum_size = Vector2(custom_min_width, custom_minimum_size.y)
