extends Sprite2D

signal speed_multiplier_changed(multiplier1, multiplier2)

@onready var indicator = $Path2D/IndicatorPath
@onready var speed_zone_container = $SpeedZoneContainer
@onready var speed_timer = $SpeedTimer
@onready var meter_change_timer = $MeterChangeTimer
@onready var tween = Threen.new()

var indicator_speed_decrease = -0.3
var indicator_speed_increase = 0.1
var check_speed_interval = 0.2
var meter_change_interval = 3
var meter_positions = [0.0, 0.2, 0.4, 0.6, 0.8]
var previous_meter_index = 0


func _ready():
	add_child(tween)
	set_process(false)
	speed_timer.timeout.connect(_on_speed_timer_timeout)
	meter_change_timer.timeout.connect(_on_meter_change_timer_timeout)
	visible = true


func start():
	set_process(true)
	speed_timer.start(check_speed_interval)
	meter_change_timer.start(meter_change_interval)


func set_active(active):
	set_process(!active)
	speed_timer.paused = active
	meter_change_timer.paused = active


func _process(delta):
	set_indicator_position(indicator_speed_decrease * delta)


func increase_speed_meter():
	set_indicator_position(indicator_speed_increase)


func set_indicator_position(value):
	indicator.progress_ratio += value


func _on_speed_timer_timeout():
	var speed = speed_zone_container.check_speed_multiplier(indicator.progress_ratio)
	if speed == null:
		return

	speed_multiplier_changed.emit(speed.mark_multiplier, speed.nicole_multiplier)


func _on_meter_change_timer_timeout():
	var index = randi() % meter_positions.size()

	while abs(index - previous_meter_index) < 2:
		index = randi() % meter_positions.size()

	previous_meter_index = index
	var random_pos = meter_positions[index]
	move_meter(random_pos)


func move_meter(offset):
	speed_zone_container.move_range(offset)
	var from = material.get_shader_parameter("offset")
	var to = Vector2(0, offset)
	tween.interpolate_property(material, "shader_parameter/offset", from, to, 0.5, Threen.TRANS_LINEAR)
	tween.start()


func stop():
	set_process(false)
	visible = false
