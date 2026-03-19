extends Label

@export var font_path: Resource
var bitmap_font: BitMap


func _ready():
	var font_data = load(font_path.resource_path)
	font_data.create_from_fnt(
		"res://scenes/_main/ch5sc12/racing-minigame/assets/UI/bitmap_font/fuelmeter_font.txt.fnt"
	)
	ResourceSaver.save(font_path, font_data)
