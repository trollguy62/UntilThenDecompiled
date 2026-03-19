extends Node3D

@export var is_enabled = false:
	set(v):
		if not is_node_ready():
			await ready
		if v:
			duration_timer.start()
		else:
			duration_timer.stop()

@export var expression_list: Array[String] = []
@export var interval: float = 4.0
@export var max_interval_variance: float = 5.0
@export var duration: float = 3.0
@export var max_bonus_duration: float = 6.0

@onready var spr = $Sprite
@onready var interval_timer = $IntervalTimer
@onready var duration_timer = $DurationTimer

func _ready():
	assert(spr != null)
	interval_timer.timeout.connect(_on_interval_timer_timeout)
	duration_timer.timeout.connect(_on_duration_timer_timeout)

func _on_interval_timer_timeout():
	spr.animation = expression_list[randi_range(0, expression_list.size() - 1)]


func _on_duration_timer_timeout():
	spr.animation = expression_list[randi_range(0, expression_list.size() - 1)]
	duration_timer.start(randf_range(duration, duration + max_bonus_duration))
