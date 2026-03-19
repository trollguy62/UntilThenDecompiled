extends Node

@export var enabled: bool
@export var anchor_follower : Node
@export var min_interval := 0.0
@export var max_interval := 1.0
@export var shoot_duration := 2.0

@onready var sprite = get_parent()
@onready var state_container: StateContainer = Utils.get_state_container_of(sprite.alias)

var start_timer = Timer.new()

var hold_anim = "camhold"
var shoot_anim = "camshoot"
var is_shooting = false

func _ready():
	start_timer.one_shot = true
	add_child(start_timer)
	start_timer.timeout.connect(_on_start_timer_timeout)

func _process(delta):
	var current_mode = state_container.dict.get_value("mode", "default")

	if current_mode == "roam":
		start_shooting()
	else:
		follow_anchor()

func start_shooting():
	if is_shooting == true:
		return

	is_shooting = true
	start_timer.start(randf_range(min_interval, max_interval))

func follow_anchor():
	if is_shooting == false:
		return

	is_shooting = false
	anchor_follower.enabled = true
	start_timer.stop()


func _on_start_timer_timeout():
	anchor_follower.enabled = false
	set_animation(hold_anim)
	await Utils.wait(1)
	set_animation(shoot_anim)
	await Utils.wait(shoot_duration)
	anchor_follower.enabled = true

	Utils.randomize()
	start_timer.start(randf_range(min_interval, max_interval))


func set_animation(state):
	var look_at = "=r" if randi_range(0,1) == 1 else ""
	var anim = "default+" + state + look_at + "_idle"
	sprite.animation = anim
