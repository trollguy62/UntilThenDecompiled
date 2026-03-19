extends Node3D

@export var min_interval = 1.0
@export var max_interval = 4.0
@export var speed = 0.15

@onready var spr = $Sprite
@onready var pg = $PathGrounder

var _path_length
var timer

func _ready():
	if timer == null:
		timer = Timer.new()
		add_child(timer)
	timer.wait_time = _get_random_interval()
	timer.timeout.connect(_on_walktimer_timeout)
	_path_length = pg.path.curve.get_baked_length()
	#start()
	#FIXME: easy way to loop without waiting, but is a hack
	_on_walktimer_timeout()

func start():
	timer.wait_time = _get_random_interval()
	timer.start()

func _on_walktimer_timeout():
	#go walk
	spr.animation = "default"
	var tween = create_tween()
	var offset = _get_random_target_offset()
	var dur = _get_duration(offset)
	spr.flip_h = _get_direction(offset)
	tween.tween_property(pg, "path_unit_offset", offset, dur)
	tween.finished.connect(_on_patrol_finished, CONNECT_ONE_SHOT)

func _on_patrol_finished():
	#spr.animation = "idle"
	#await get_tree().create_timer(_get_random_interval())
	#start()
	#FIXME: easy way to loop without waiting, but is a hack
	_on_walktimer_timeout()

func _get_duration(offset):
	return abs(offset - pg.path_unit_offset) / speed

func _get_random_interval():
	return randf_range(min_interval, max_interval)

func _get_random_target_offset():
	return randf()

func _get_direction(offset):
	return offset - pg.path_unit_offset > 0
