extends PanelContainer

const REQ_WIDTH = 260.0
const MAX_HEIGHT = 600.0
const STICKER_SIZE = 60.0

@onready var picture_btn = $Picture

var picture: Texture:
	set = _set_picture,
	get = _get_picture
var align_right := false:
	set = _set_align_right,
	get = _get_align_right
var sticker := false:
	set = _set_sticker,
	get = _get_sticker


func _ready():
	self.picture = picture
	self.align_right = align_right
	self.sticker = sticker
	if self.sticker:
		self.material = null

	draw.connect(_on_draw)


func _on_draw():
	var size = Vector2.ONE

	if sticker:
		size *= STICKER_SIZE
	else:
		var w = REQ_WIDTH
		var h = picture.get_height() * (REQ_WIDTH / picture.get_width())
		size *= Vector2(w, min(h, MAX_HEIGHT))

	picture_btn.custom_minimum_size = size
	picture_btn.material.set_shader_parameter("size", size)


func _set_picture(value):
	picture = value
	if picture_btn != null:
		picture_btn.picture = picture


func _process(delta):
	#FIXME: no idea why i have to reset the shader every frame instead of the setter, but it only works if you do it like this
	if picture_btn.material:
		picture_btn.material.set_shader_parameter("image_resolution", picture_btn.custom_minimum_size)


func _get_picture():
	return picture


func _set_align_right(value):
	align_right = value
	if picture_btn != null:
		picture_btn.size_flags_horizontal = SIZE_SHRINK_END if align_right else 0


func _get_align_right():
	return align_right


func _set_sticker(value):
	sticker = value
	if picture_btn != null:
		picture_btn.anim_hover = not sticker
		picture_btn.open_alt = not sticker
		picture_btn.mouse_filter = MOUSE_FILTER_IGNORE if sticker else MOUSE_FILTER_STOP


func _get_sticker():
	return sticker
