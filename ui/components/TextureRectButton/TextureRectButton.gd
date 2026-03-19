extends TextureRect

signal pressed

const PictureScreen = preload("res://ui/screens/PictureScreen/PictureScreen.tscn")
const Clickable = preload("res://ui/components/Clickable.gd")

const MOD_IDLE = Color(1, 1, 1)
const MOD_HOVER = Color(0.85, 0.85, 0.85)
const ANIM_DUR = 0.1

@export var anim_hover = true
@export var open_alt = true
@export var fit_width = false:
	set(value):
		fit_width = value
		_update()
	get:
		return fit_width

@export var placeholder_color = Color(0.9, 0.9, 0.9)
@export var load_delay = 0.0

@onready var tween = Threen.new()
@onready var timer = Timer.new()
@onready var clickable = Control.new()
@onready var btn = $Button

var picture:
	set = _set_picture,
	get = _get_picture

var alt_picture
var alt_route: String = ""
var alt_route_payload: Dictionary = {}
var alt_load_delay = 0.0

var _has_loaded = false


func _ready():
	timer.one_shot = true
	timer.timeout.connect(_load_texture)

	clickable.set_script(Clickable)

	add_child(tween)
	add_child(timer)
	#add_child(clickable)
#	btn.flat = true
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	btn.focus_entered.connect(_on_hovered)
	btn.mouse_entered.connect(_on_hovered)
	btn.focus_exited.connect(_on_unhovered)
	btn.mouse_exited.connect(_on_unhovered)
	btn.pressed.connect(_on_pressed)
	#add_child(btn)

	self.picture = picture


func _set_picture(value):
	if value == null:
		value = texture

	picture = value
	_has_loaded = false
	modulate = MOD_IDLE

	if timer != null:
		texture = preload("res://assets/ui/hint_white.png")
		modulate = placeholder_color

		if load_delay > 0:
			timer.start(load_delay)
		else:
			_load_texture()


func _get_picture():
	return picture


func _load_texture():
	if picture is Texture:
		_on_loaded_texture(picture)
	elif picture is String:
		_on_loaded_texture(load(picture))


func _on_loaded_texture(texture):
	self.texture = texture
	modulate = Color.WHITE
	_has_loaded = true
	_update()



func _update():
	if fit_width and tween and texture:
		await get_tree().process_frame
		var s = get_parent().size
		var i = texture.get_size()
		custom_minimum_size = Vector2(s.x, i.y * (s.x / i.x))


func _on_hovered():
	if has_focus():
		return
	_anim_modulate(true)


func _on_unhovered():
	_anim_modulate(false)


func _on_pressed():
	if not open_alt or not _has_loaded:
		return

	btn.disabled = true
	if alt_route.is_empty():
		_open_picture_screen()
	else:
		_open_alt_route()
	
	pressed.emit()
	#FIXME: hack
	await get_tree().create_timer(2).timeout
	btn.disabled = false


func _anim_modulate(hover: bool):
	if not anim_hover or not _has_loaded:
		return

	var mod = [MOD_IDLE, MOD_HOVER]
	if not hover:
		mod.reverse()
	tween.interpolate_property(
		self, "modulate", mod[0], mod[1], ANIM_DUR, Threen.TRANS_LINEAR, Threen.EASE_IN
	)
	tween.start()


func _open_picture_screen():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator != null:
		var picture = alt_picture if alt_picture != null else texture
		navigator.push_named("/picture", {"picture": picture, "load_delay": alt_load_delay})


func _open_alt_route():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator != null:
		navigator.push_named(alt_route, alt_route_payload)
