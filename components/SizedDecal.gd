@tool
extends Decal

@export_range(0.001, 1.0) var pixel_size := 0.01
@export_range(0.001, 1.0) var depth := 0.001


func _ready():
	if not Engine.is_editor_hint():
		set_process(false)


func _process(delta):
	if Engine.is_editor_hint() and texture_albedo:
		var tex_size = texture_albedo.get_size() * pixel_size
		size = Vector3(tex_size.x, depth, tex_size.y)
