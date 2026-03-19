extends Node

@export var robots_paths: Array[NodePath] = []
@export var animation := "default"
@export var stop_delay := 1.0

@onready var timer := Timer.new()

var _robots := []
var _playing := false


func _ready():
	timer.one_shot = true
	add_child(timer)

	for robot_path in robots_paths:
		var robot = get_node(robot_path)
		assert(robot is AnimatedPaper3D)
		_robots.append(robot)

		robot.stop()
		robot.animation_finished.connect(_on_animation_finished.bind(robot))

	get_parent().entered.connect(_on_entered)
	get_parent().exited.connect(_on_exited)
	timer.timeout.connect(_on_timer_timeout)


func _on_entered():
	_playing = true

	for robot in _robots:
		if not robot.playing:
			robot.play(animation, true)


func _on_exited():
	timer.start(stop_delay)


func _on_timer_timeout():
	_playing = false


func _on_animation_finished(robot: AnimatedPaper3D):
	if not _playing:
		robot.stop()
