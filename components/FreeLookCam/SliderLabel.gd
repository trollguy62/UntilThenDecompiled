extends Label

@export var slider_path: NodePath
@export_range(0, 3) var dec_place: int = 0

@onready var slider: Slider = get_node(slider_path)


func _ready():
	slider.value_changed.connect(_on_slider_value_changed)
	_on_slider_value_changed(slider.value)


func _on_slider_value_changed(value: float):
	text = ("%." + str(dec_place) + "f") % snapped(value, pow(0.1, dec_place))
