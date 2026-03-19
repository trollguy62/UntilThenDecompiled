extends Node2D

const P1_EDGE = 1
const P2_EDGE = 1
const COLLISION_OFFSET_X_PX = 3

@onready var p2 = $LomNicole
@onready var p1 = $LomMark
@onready var _beam_collision = $BeamCollision
@onready var _base_collision_pos = _beam_collision.global_position

var _points: int = 0
var _beam_velocity = Vector2()


func _ready():
	p2.mashed.connect(_on_p2_mashed)
	p1.mashed.connect(_on_p1_mashed)
	$DebugTimer.timeout.connect(_on_d_timer_timeout)
	update_controls()


func _on_p1_mashed():
	_points -= P1_EDGE
	update_controls()


func _on_p2_mashed():
	_points += P2_EDGE
	update_controls()


func update_controls():
	$Label.text = str(_points)
	var _collision_offset = -COLLISION_OFFSET_X_PX * _points
	var _target_pos = _base_collision_pos
	_target_pos.x += _collision_offset
	_beam_velocity.x = _collision_offset / 1.0


func _process(delta):
	_beam_collision.position += _beam_velocity * delta


#FOR DEBUG ONLY
func _input(event):
	if event.is_action_pressed("choice_1"):
		p2.emit_signal("mashed")
	if event.is_action_pressed("choice_2") or event.is_action_pressed("c_interact"):
		_beam_collision.position.x += 10
		p1.emit_signal("mashed")
	if event.is_action_pressed("choice_3"):
		$DebugTimer.start()


func _on_d_timer_timeout():
	p2.emit_signal("mashed")
#
