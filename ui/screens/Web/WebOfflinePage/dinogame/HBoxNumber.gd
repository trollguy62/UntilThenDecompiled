extends HBoxContainer

const DIGIT_TEXTURES = [
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_0.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_1.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_2.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_3.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_4.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_5.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_6.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_7.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_8.png"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/assets/txt_9.png")
]

var number: int:
	set = _set_number,
	get = _get_number

var is_ready := false


func _ready():
	is_ready = true
	self.number = number


func _set_number(value):
	number = abs(value)
	if not is_ready:
		return

	var digit_count = get_child_count()
	var str_n = ("%" + ("0%d" % digit_count) + "d") % number

	for i in digit_count:
		var digit = int(str_n[i])
		var digit_view: TextureRect = get_child(i)
		digit_view.texture = DIGIT_TEXTURES[digit]


func _get_number():
	return number
