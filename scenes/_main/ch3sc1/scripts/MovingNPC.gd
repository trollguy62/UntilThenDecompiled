extends Node

@export var min_interval : float
@export var max_interval : float
@export var speed : float

@onready var visible_notifier : VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var sprite = $Sprite
@onready var timer = Timer.new()
@onready var path_grounder = $PathGrounder

var moving = false
var target_direction: int  = 1
enum  Direction {LEFT = -1, RIGHT= 1}


func _ready():
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	reset()


func _process(delta):
	if moving:
		check_progress()


func check_progress():
	if path_grounder.path_unit_offset <= 0 and target_direction == 0:
		on_end_reached()

	if path_grounder.path_unit_offset >= 1 and target_direction == 1:
		if not visible_notifier.is_on_screen():
			on_end_reached()
		else:
			set_move_direction(Direction.LEFT)
			move()


func reset():
	sprite.visible = false
	moving = false
	
	var interval = randf_range(min_interval,max_interval)
	timer.one_shot = true
	timer.start(interval)
	
	var dir = Direction.RIGHT if randi() % 2 == 0 else Direction.LEFT
	path_grounder.offset_speed = 0
	path_grounder.clear_target()
	set_move_direction(dir)	


func on_end_reached():
	reset()


func _on_timer_timeout():	
	if path_grounder.path_unit_offset == 1 and visible_notifier.is_on_screen():
		set_move_direction(Direction.RIGHT)

	await get_tree().process_frame
	await get_tree().process_frame
	sprite.visible = true	
	move()


func set_move_direction(dir):
	
	if dir == Direction.RIGHT:
		target_direction = 1
		path_grounder.path_unit_offset = 0
		sprite.flip_h = true
	else:
		target_direction = 0
		path_grounder.path_unit_offset = 1
		sprite.flip_h = false


func move():
	moving = true
	path_grounder.offset_speed = speed if target_direction == 1 else -speed
	path_grounder.set_target_unit_offset(target_direction,speed)
