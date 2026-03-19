extends Node2D

const OBSTACLES = [
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/Cactus1.tscn"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/Cactus2.tscn"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/Cactus3.tscn"),
	preload("res://ui/screens/Web/WebOfflinePage/dinogame/Cactus4.tscn")
]
const OBSTACLE_INITIAL_POS = Vector2(160, 69)

@export var start_now := false

@onready var timer = $Timer
@onready var tween = Threen.new()
@onready var root = $Root
@onready var player = $Dino
@onready var obstacle_container = $Root/Obstacles
@onready var high_score = $Root/Scores/High/HighScore
@onready var cur_score = $Root/Scores/CurScore
@onready var game_over = $GameOver
@onready var animation_player = $AnimationPlayer

var started = false:
	set(v):
		started = v
		animation_player.stop()

	get: return started
var is_over = false:
	get: return is_over

var score := 0.0
var last_high_score := 0


func _ready():
	add_child(tween)

	last_high_score = WebUtils.dinogame_high_score
	high_score.number = last_high_score

	player.set_process(false)
	if start_now:
		start(0)


func _process(delta):
	if not started and Input.is_action_just_pressed("interact"):
		start()

	if started and not is_over:
		score += delta * 10
		cur_score.number = score
		high_score.number = max(last_high_score, score)


func start(anim_dur: float = 0.5):
	started = true

	var c0 = root.modulate
	var c1 = c0
	c1.a = 1
	tween.interpolate_property(root, "modulate", c0, c1, anim_dur)
	tween.start()
	await tween.tween_all_completed

	timer.start(0.5)
	timer.timeout.connect(_add_obstacle)
	player.set_process(true)


func _add_obstacle():
	var packed_obstacle = OBSTACLES[randi() % OBSTACLES.size()]
	var obstacle = packed_obstacle.instantiate()
	obstacle.position = OBSTACLE_INITIAL_POS
	obstacle_container.add_child(obstacle)
	timer.start(randf_range(0.5, 1.6))


func stop():
	is_over = true
	game_over.visible = true
	timer.timeout.disconnect(_add_obstacle)

	set_paused(true)
	set_paused(true, player)

	if score > last_high_score:
		WebUtils.dinogame_high_score = score


func set_paused(paused: bool, node: Node = root):
	var active = not paused
	node.set_process(active)
	node.set_physics_process(active)
	node.set_process_input(active)

	for child in node.get_children():
		set_paused(paused, child)

func play_idle():
	animation_player.play("idle_animation")

func stop_idle():
	animation_player.stop()
