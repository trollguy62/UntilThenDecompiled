extends Area3D

signal interacted

enum Preset { NONE, ICON_POINTER, ICON_EYE, ICON_BUBBLE, ICON_UP, ICON_DOWN, ICON_LEFT, ICON_RIGHT }

@onready var handler = Service.of("InteractiveAreaHandler")
@onready var scene_manager = Service.of("SceneManager")

@onready var anchor
@onready var collider = _get_child_of_type("CollisionShape")
@onready var control = $Control
@onready var label = $Control/Label
@onready var icon_rect = $Control/Icon
@onready var tween = Threen.new()

@export var enabled = true:
	set(value):
		if enabled != value:
			enabled = value
			update()

@export var max_interact_count = 0:
	set(value):
		max_interact_count = value
		update()
@export var preset: Preset = Preset.ICON_POINTER
@export var text = "Interact"
@export var icon: Texture
@export var story_signal = ""
@export var short_knot = ""

var interact_count = 0

var _player_entered = false


func _ready():
	add_child(tween)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	anchor = _get_child_of_type("Marker3D")
	if anchor == null:
		anchor = Marker3D.new()
		add_child(anchor)

	control.size = Vector2.ZERO
	control.visible = false

	if preset != Preset.NONE:
		text = ""
		icon = {
			Preset.ICON_POINTER: preload("res://assets/ui/ic_touch.png"),
			Preset.ICON_EYE: preload("res://assets/ui/ic_eye.png"),
			Preset.ICON_BUBBLE: preload("res://assets/ui/ic_speech_bubbles_128px.png"),
			Preset.ICON_UP: preload("res://assets/ui/ic_north.png"),
			Preset.ICON_DOWN: preload("res://assets/ui/ic_south.png"),
			Preset.ICON_LEFT: preload("res://assets/ui/ic_west.png"),
			Preset.ICON_RIGHT: preload("res://assets/ui/ic_east.png")
		}[preset]

	if icon == null:
		label.text = text
		label.visible = true
	else:
		icon_rect.texture = icon
		icon_rect.visible = true


func _process(delta):
	if control.visible:
		_update_control()


func _get_configuration_warning():
	if _get_child_of_type("CollisionShape") == null:
		return "Must have a CollisionShape"
	return ""


func _on_area_entered(area: Area3D):
	if area.get_collision_layer_value(Constants.PLAYER_COLLISION_LAYER):
		_player_entered = true
		update()


func _on_area_exited(area: Area3D):
	if area.get_collision_layer_value(Constants.PLAYER_COLLISION_LAYER):
		_player_entered = false
		update()


func is_enabled() -> bool:
	return (
		enabled
		and is_visible_in_tree()
		and not max_interact_count < 0
		and (max_interact_count == 0 or interact_count < max_interact_count)
	)


func show():
	_update_control()
	_animate(true)
	$Hover.play()


func hide():
	_animate(false)


func _animate(show: bool):
	var scale = [control.scale, Vector2.ONE * (1.0 if show else 0.7)]
	var color = [control.modulate, Color.WHITE if show else Color.TRANSPARENT]
	if show:
		control.visible = true

	tween.stop_all()
	tween.interpolate_property(control, "scale", scale[0], scale[1], 0.2)
	tween.interpolate_property(control, "modulate", color[0], color[1], 0.2)
	tween.start()

	await tween.tween_all_completed
	if not show:
		control.visible = false


func interact():
	if not is_enabled():
		return

	interacted.emit()
	interact_count += 1

	if story_signal != "":
		Story.emit(story_signal)
	if short_knot != "" and scene_manager:
		var scene_id = scene_manager.scene_id
		var id = "%s.%s" % [scene_id, short_knot]
		await Story.start_short(id)

	update()


func update():
	if handler == null:
		return
	if is_enabled() and _player_entered:
		handler.push(self)
	else:
		handler.pop(self)


func _update_control():
	var camera = get_viewport().get_camera_3d()
	control.pivot_offset = control.size / 2
	control.position = (
		camera.unproject_position(anchor.global_transform.origin)
		- control.pivot_offset
	)


func _get_child_of_type(type: String) -> Node:
	for child in get_children():
		if child.is_class(type):
			return child
	return null
