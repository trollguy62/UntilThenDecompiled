extends "../Screen.gd"

signal loaded_picture

@export var load_delay = 0.0

var picture:
	set = _set_picture,
	get = _get_picture

var hide_back_btn := false

@onready var tex_rect = $TextureRect
@onready var spinner = $Spinner
@onready var menu_bar = $MenuBar
@onready var back_btn = $MenuBar/BackButton

func _ready():
	if hide_back_btn:
		menu_bar.visible = false
	spinner.visible = false
	self.picture = picture
	back_btn.disabled = true

func _before_show():
	super._before_hide()
	back_btn.disabled = true

func _after_show():
	super._after_show()
	back_btn.disabled = false

func _before_hide():
	super._before_hide()
	back_btn.disabled = true

func _set_picture(value):
	picture = value
	if tex_rect == null:
		return

	if load_delay > 0.0:
		spinner.visible = true
		await Utils.wait(load_delay)

	tex_rect.scale = Vector2.ONE
	tex_rect.position = Vector2.ZERO

	if picture is Texture:
		tex_rect.texture = picture
	elif picture is String:
		tex_rect.texture = load(picture)

	spinner.visible = false
	loaded_picture.emit()


func _get_picture():
	return picture


func get_picture_pos():
	return (size - get_picture_size()) / 2.0


func get_picture_size():
	return Utils.cover_aspect_size(picture.get_size(), size)

func _unhandled_input(event):
	if event.is_action_pressed("c_cancel"):
		#prevents event from propagating
		accept_event()
		back_btn.press()
#		#back_btn.disabled = true

	if event.is_action_pressed("d_up") or event.is_action_pressed("d_left"):
		if focus_on_enter is Control and not tex_rect._zoomed:
			focus_on_enter.call_deferred("grab_focus")
