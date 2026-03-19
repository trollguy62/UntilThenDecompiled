extends Control

signal loaded_picture

@export var load_delay = 0.0

var picture:
	set = _set_picture,
	get = _get_picture

@onready var tex_rect = $TextureRect
@onready var spinner = $Spinner

func _ready():
	spinner.visible = false
	self.picture = picture

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
