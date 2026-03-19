extends Area2D

signal hover_started
signal selected

const HOVER_DY = 10
const REVEAL_DY = 30
const PULL_OUT_DY = 200

@onready var tween = Threen.new()
@onready var collider = $CollisionPolygon2D
@onready var sprite = $Sprite
@onready var original_pos = position

var selection_enabled := false
var _base_y := 0.0
var _collider_global_pos := Vector2()


func _ready():
	add_child(tween)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)

	_base_y = position.y
	_collider_global_pos = collider.global_position


func _process(delta):
	collider.disabled = not selection_enabled

	# Permanently fix collider (mouse input bounds) into place
	# This effectively avoids a bug where the paper "shakes"
	collider.global_position = _collider_global_pos


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit()


func _on_mouse_entered():
	if selection_enabled:
		hover_started.emit()
		_anim_dy(HOVER_DY, 0.1)


func _on_mouse_exited():
	if selection_enabled:
		_anim_dy(0, 0.1)


func restore():
	position.y = _base_y
	visible = true


func reveal():
	await _anim_dy(REVEAL_DY, 0.4)



func unreveal():
	await _anim_dy(0, 0.4)


func pull_out():
	await _anim_dy(PULL_OUT_DY, 0.5)
	visible = false


func _anim_dy(dy: float, dur: float):
	var p0 = position
	var p1 = Vector2(p0.x, _base_y - dy)

	tween.stop_all()
	tween.interpolate_property(self, "position", p0, p1, dur, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT)
	tween.start()

	await tween.tween_completed
