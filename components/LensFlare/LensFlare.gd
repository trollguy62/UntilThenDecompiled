@tool
extends Node2D

@export var sun_position = Vector2(0, 0):
	set(value):
		sun_position = value
		if is_inside_tree():
			_update_material()
@export var tint = Color(1, 0.85714, 0.71428):
	set(value):
		tint = value
		if is_inside_tree():
			_update_material()

@export_range(0, 32) var strength: float = 1.4:
	set(value):
		strength = value
		if is_inside_tree():
			_update_material()

@export var use_back_buffer = false:
	set(value):
		use_back_buffer = value
		if is_inside_tree():
			_back_buffer.copy_mode = (
				BackBufferCopy.COPY_MODE_VIEWPORT
				if use_back_buffer
				else BackBufferCopy.COPY_MODE_DISABLED
			)


@onready var _back_buffer = $BackBufferCopy
@onready var _color_rect = $BackBufferCopy/ColorRect
@onready var _parent_camera = get_parent() as Camera3D

@onready var _material = _color_rect.material.duplicate() as ShaderMaterial


func _ready():
	_color_rect.material = _material

	self.use_back_buffer = use_back_buffer
	_update_material()


func _process(_delta):
	visible = strength > 0 and (not _parent_camera or _parent_camera.current)


func _update_material():
	_material.set_shader_parameter("sun_position", sun_position)
	_material.set_shader_parameter("tint", Vector3(tint.r, tint.g, tint.b) * strength)
