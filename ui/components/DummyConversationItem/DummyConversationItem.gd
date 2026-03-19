extends Control

@onready var title = $HBox/VBox/Title
@onready var subtitle = $HBox/VBox/Subtitle


func _ready():
	Utils.randomize()

	var title_width = randf_range(100, 250)
	var subtitle_width = randf_range(60, 300)

	title.custom_minimum_size.x = title_width
	title.size.x = title_width

	subtitle.custom_minimum_size.x = subtitle_width
	subtitle.size.x = subtitle_width
