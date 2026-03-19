@tool
extends Label

@export_range(0.0, 1.0, 0.01) var progress: float = 0.5:
	set(v):
		progress = clamp(v, 0.0, 1.0)
		size.x = progress * get_parent_area_size().x


func _ready():
	resized.connect(_on_resized)


#workaround to 1px min size showing
func _on_resized():
	if size.x <= 1:
		hide()
	else:
		show()
