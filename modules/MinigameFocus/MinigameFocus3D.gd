extends Node3D

const EYE = preload("res://assets/ui/ic_eye.png")
const ARROW = preload("res://assets/ui/cursors/pointer.png")

signal target_clarity_reached


@export var focus_duration = 5.0:
	set(v):
		focus_duration = v
		if not is_inside_tree():
			await ready
		rate = _intensity_base / focus_duration

@export var auto_camera = false
@export var pullback_duration = 0.1

@onready var subcam: Camera3D = $SubViewport/Camera3D
@onready var trect = $CanvasLayer/Control/TextureRect
@onready var label = $CanvasLayer/Label
@onready var area = $CanvasLayer/TargetArea
@onready var anim_player = $AnimationPlayer
@onready var blur_layer = $CanvasLayer
@onready var color_rect = $CanvasLayer/Control/ColorRect
var is_focused = false:
	set(v):
		is_focused = v
		if not is_focused:
			var tween = get_tree().create_tween()
			tween.tween_property(trect, "intensity", _intensity_base, pullback_duration)
			#tween.tween_property(trect, "focus_position", get_viewport().get_mouse_position(), pullback_duration)
			tween.set_parallel(true)
			_current_intensity = _intensity_base
			tween.set_trans(Tween.TRANS_CUBIC)
			if is_prospero:
				Prospero_Cursor.texture = ARROW
			else:
				Input.set_custom_mouse_cursor(null)
			#trect.material.set_shader_parameter("mouse_position", get_viewport().get_mouse_position())

var rate = 0.0035

var freeze = false
var target_clarity: float = 1.0 #1.0 fully clear, 0.0 fully blurry
var _intensity_base
var _current_intensity
var _has_signalled = false
var is_prospero = false
var Prospero_Cursor

func _ready():
	area.mouse_entered.connect(set.bind("is_focused", true))
	area.mouse_exited.connect(set.bind("is_focused", false))
	area.input_pickable = false
	visibility_changed.connect(_on_visibility_changed)

	trect.cleared.connect(_on_cleared)
	_intensity_base = trect.intensity
	_current_intensity = trect.intensity
	trect.texture = $SubViewport.get_texture()
	color_rect.hide()

	blur_layer.visible = visible
	is_prospero = OS.get_name() == "Prospero"
	if is_prospero:
		Prospero_Cursor = get_node("CanvasLayer").get_node("Pointer").get_node("Prospero_Cursor")
	#start(1.0)

func _process(delta):
	if get_viewport().get_camera_3d() != null:
		var camera = get_viewport().get_camera_3d()
		subcam.global_transform = camera.get_camera_transform()
		subcam.fov = camera.fov
		subcam.near = camera.near
		subcam.far = camera.far
		if camera.attributes != null:
			subcam.attributes = camera.attributes
		else:
			subcam.attributes = null

	if not is_focused:
		trect.focus_position = get_viewport().get_mouse_position()
		return

	if not freeze:
		if is_prospero:
			Prospero_Cursor.texture = EYE
		else:
			Input.set_custom_mouse_cursor(EYE, 0, Vector2(48, 48))
		_current_intensity -= delta * rate
		trect.intensity = _current_intensity
		var m_pos: Vector2 = trect.focus_position
		var current_m_pos: Vector2 = get_viewport().get_mouse_position()
		var pos_diff = get_viewport().get_mouse_position() - trect.focus_position
		if pos_diff.length_squared() > 0.02:
			m_pos += pos_diff / 2.0 * delta
			trect.focus_position = m_pos

		var clarity = (_intensity_base - trect.intensity) / _intensity_base
		if clarity >= target_clarity and not _has_signalled:
			target_clarity_reached.emit()
			_has_signalled = true
			set_process(false)
			disable_input()

		_update_debug_label(clarity)

func _update_debug_label(completion):
	var percent_completion = completion * 100
	label.text = "Completion: %.2f" % percent_completion + "%"

func fade_in():
	color_rect.show()
	anim_player.play("fade_in")
	await anim_player.animation_finished

func fade_out():
	anim_player.play("fade_out")
	await anim_player.animation_finished
	color_rect.hide()

func start(target: float):
	if target < 0.0:
		printerr("Value should be non-negative!")
		target = 0.0

	show()
	set_process(true)
	target_clarity = target
	area.input_pickable = true
	_has_signalled = false
	var tween = get_tree().create_tween()
	tween.tween_property(trect, "intensity", trect.intensity, 1.5).from(0.0)
	await tween.finished

func relocate():
	area.relocate()

func disable_input():
	area.input_pickable = false

func _on_visibility_changed():
	blur_layer.visible = visible

func _on_cleared():
	area.set_process(false)
	area.fade()
