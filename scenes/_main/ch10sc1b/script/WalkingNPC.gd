extends PathFollow3D

@export var min_interval : float
@export var max_interval : float
@export var speed : float

@onready var visible_notifier : VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var sprite = $Sprite
@onready var timer = $Timer

var direction: int  = 1

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	reset()

func _process(delta):
	if sprite.is_visible_in_tree():
		progress += delta * (direction * speed)
		check_progress()

func check_progress():
	if progress_ratio == 1:
		on_end_reached()

	if progress_ratio == 0:
		if not visible_notifier.is_on_screen():
			on_end_reached()
		else:
			direction = 1
			sprite.flip_h = true

func reset():
	sprite.visible = false
	var interval = randf_range(min_interval,max_interval)
	timer.start(interval)
	timer.one_shot = true

func on_end_reached():
	reset()

func _on_timer_timeout():
	var dir = 1 if randi() % 2 == 0 else -1
	set_direction(dir)

	await get_tree().process_frame

	if direction == 1 and visible_notifier.is_on_screen():
		set_direction(-1)

	sprite.visible = true

func set_direction(dir):
	direction = dir

	if direction == 1:
		progress_ratio = 0
		sprite.flip_h = true
	else:
		progress_ratio = 1
		sprite.flip_h = false
