extends HBoxContainer

signal selected_changed

const COLOR_IDLE = Color.BLUE
const COLOR_CURRENT = Color.YELLOW
const COLOR_SELECTED = Color.RED

@onready var name_label = $Name
@onready var button = $Button

var station_name: String : set= _set_station_name, get = _get_station_name
var current = false :set = _set_current, get = _get_current
var selected = false :set = _set_selected, get =_get_selected


func _ready():
	button.pressed.connect(_on_button_pressed)
	self.station_name = station_name
	self.current = current
	self.selected = selected


func _set_station_name(value):
	station_name = value
	if name_label != null:
		name_label.text = station_name


func _get_station_name():
	return station_name


func _set_current(value):
	current = value
	if button != null:
		_update_button()


func _get_current():
	return current


func _set_selected(value):
	selected = value
	if button != null:
		_update_button()


func _get_selected():
	return selected


func _update_button():
	if current:
		button.modulate = COLOR_CURRENT
	elif selected:
		button.modulate = COLOR_SELECTED
	else:
		button.modulate = COLOR_IDLE


func _on_button_pressed():
	if not current:
		selected = not selected
		_update_button()
		selected_changed.emit()
