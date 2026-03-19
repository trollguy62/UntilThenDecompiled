extends PanelContainer

var internal_resolution := Vector2.ZERO
var _is_clicked := false


func _ready():
	internal_resolution.x = ProjectSettings.get_setting("display/window/size/viewport_width")
	internal_resolution.y = ProjectSettings.get_setting("display/window/size/viewport_height")


func _process(delta):
	pass


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_clicked = event.is_pressed()


func consume_click() -> bool:
	var c = _is_clicked
	_is_clicked = false
	return c


func get_percent_visible_area() -> float:
	var area: float = size.x * size.y

	var length_x_in_bounds: float = (
		clamp(global_position.x + size.x, 0, internal_resolution.x)
		- clamp(global_position.x, 0, internal_resolution.x)
	)
	var length_y_in_bounds: float = (
		clamp(global_position.y + size.y, 0, internal_resolution.y)
		- clamp(global_position.y, 0, internal_resolution.y)
	)

	var area_in_bounds: float = length_x_in_bounds * length_y_in_bounds

	var percent_area_visible: float = area_in_bounds / area

	return percent_area_visible
