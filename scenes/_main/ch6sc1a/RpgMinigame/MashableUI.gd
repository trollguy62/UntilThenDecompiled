@tool
extends AnimatedSprite2D

const TARGET_SCALE = Vector2(3.5, 3.5)

signal player_ready

@export var max_scale_change = 0.5
@onready var auto_mash_timer = $AutoMashTimer

var _og_scale: Vector2
var _base_scale: Vector2 = Vector2(2.0, 2.0)
var _t = 0
var _player_ready = false


func _ready():
	animation = "mash"
	_og_scale = scale
	_base_scale = scale
	player_ready.connect(_on_player_ready)
	auto_mash_timer.timeout.connect(_on_auto_mash_timer_timeout)


func reset():
	_base_scale = _og_scale
	scale = _og_scale
	_player_ready = false


func mash(auto = false):
	if _player_ready:
		auto = false
		auto_mash_timer.stop()
		return

	if _base_scale.x >= TARGET_SCALE.x:
		emit_signal("player_ready")
	_base_scale += Vector2(0.1, 0.1)
	_t = 0.0

	if auto:
		auto_mash_timer.start()


func _on_auto_mash_timer_timeout():
	mash()


func _process(delta):
	if _player_ready or Engine.is_editor_hint():
		return

	scale = _base_scale + 0.5 * max_scale_change * Vector2(cos(3 * _t), cos(3 * _t))
	_t += delta
	_t = fmod(_t, 3600.0)


func _on_player_ready():
	_player_ready = true
	animation = "ready"
	#scale = TARGET_SCALE
