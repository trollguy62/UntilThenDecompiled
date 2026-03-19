extends PanelContainer

@onready var label_file_name = $VBox/FileName
@onready var label_file_size = $VBox/FileSize

var file_name: String:
	set(value):
		file_name = value
		if _is_ready:
			label_file_name.text = file_name
	get:
		return file_name

var file_size_bytes: int:
	set(value):
		file_size_bytes = value
		if _is_ready:
			label_file_size.text = Utils.parse_file_size(file_size_bytes, 1)
	get:
		return file_size_bytes

var _is_ready = false


func _ready():
	_is_ready = true
	self.file_name = file_name
	self.file_size_bytes = file_size_bytes
