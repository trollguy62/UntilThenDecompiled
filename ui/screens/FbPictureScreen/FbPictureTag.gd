extends "res://ui/components/Clickable.gd"

const FbPictureTag = preload("res://data/fb/FbPictureTag.gd")

var tag: FbPictureTag
var parent_offset = Vector2.ZERO
var parent_size = Vector2.ONE
var image_size = Vector2.ONE


func _ready():
	pressed.connect(_on_pressed)


func reposition():
	var size_factor = parent_size / image_size
	position = parent_offset + tag.position * size_factor
	size = tag.size * size_factor


func _on_pressed():
	var navigator = Service.of(Service.NAVIGATOR)
	if navigator:
		navigator.push_named(tag.route)


func _on_mouse_entered():
	super._on_mouse_entered()
	modulate.a = 0.9


func _on_mouse_exited():
	super._on_mouse_exited()
	modulate.a = 0.5
