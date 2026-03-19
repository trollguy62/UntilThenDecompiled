extends Node2D

signal trace_finished

@export var use_high_resolution = false
@export var target_sprite: Sprite2D
@export var target_path: Path2D:
	set(v):
		target_path = v
		if not is_inside_tree():
			await _ready()
		path.curve = target_path.curve

		line.points = path.curve.tessellate() if use_high_resolution else path.curve.get_baked_points()

@export var start_radius = 10.0
@export var trace_color : Color

@onready var path = $InternalPath2D
@onready var target = $InternalPath2D/Target
@onready var marker = $InternalPath2D/PathFollow2D/Marker2D
@onready var line = $InternalPath2D/Line2D
@onready var area = $Area2D

var is_active = false

func _ready():
	if target_sprite == null:
		target_sprite = get_node_or_null("Sprite")
	if target_path == null:
		target_path = get_node_or_null("Path2D")

	target_sprite.hide()
	#hacks for legacy code...
	line.self_modulate = trace_color

	path.global_transform = target_path.global_transform
	area.global_position = path.to_global(path.curve.get_point_position(0))

	area.input_event.connect(_input_event)
	path.finished.connect(_on_finished)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			start()

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_active:
				path.reset()
			target.enabled = false

func _on_finished():
	is_active = false
	target_sprite.show()
	trace_finished.emit()
	area.input_pickable = false
	path.hide()
	line.hide()

func _get_configuration_warnings():
	if target_sprite == null or target_path == null:
		return ["This node requires both a Sprite2D and a Path2D to work."]

func start():
	path.enabled = true
	target.enabled = true
	is_active = true
	target_sprite.hide()
	area.input_pickable = true
	path.show()
	show()

func get_current_marker_position():
	return marker.global_position
