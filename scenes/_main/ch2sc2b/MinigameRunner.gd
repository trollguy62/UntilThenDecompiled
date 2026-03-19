extends Node

signal game_finished
signal mark_tripped

const BLDG_OFFSET_X = -10.16
const BLDG_COUNT = 2

const RepeatingSection = preload("res://scenes/_main/ch2sc2b/assets/MinigameRunner/prefabs/RepeatingSection.tscn")
const Obstacle = preload("res://scenes/_main/ch2sc2b/scripts/MinigameRunner/Obstacle.gd")

@export var world_path: NodePath
@export var characters_path: NodePath
@export var short_path: String

@export var scroll_speed: float = 1
@export var obstacles : Array[PackedScene]
@export var pre_obstacle_shorts : Array[String] = []

@export var student_props: Array[PackedScene]

@export var obstacle_interval_min: float = 4
@export var obstacle_interval_max: float = 6
@export var student_prop_interval_min: float = 5
@export var student_prop_interval_max: float = 10
@export var qte_time_scale: float = 0.5
@export var c2d_reaction_show_duration: float = 2.0
@export var player_path: NodePath

@onready var world = get_node(world_path)
@onready var characters = get_node(characters_path)

@onready var bldg_group = Node3D.new()
@onready var obstacle_group = Node3D.new()
@onready var student_props_group = Node3D.new()

@onready var timer_obstacle = $TimerObstacle
@onready var timer_prop = $TimerProp
@onready var qte = $QTE
@onready var reaction_c2d = $ReactionC2D
@onready var reaction_sfx = $ReactionSFX
@onready var player = get_node(player_path) as Node3D

var _bldg_queue := []
var _current_obstacle: Obstacle
var _obstacle_idx := -1
var _pause_scroll := false
var _game_started := false
var _student_walk_speed := 1.5


func _ready():
	assert(obstacles.size() == pre_obstacle_shorts.size())

	timer_obstacle.timeout.connect(_spawn_obstacle)
	timer_prop.timeout.connect(_spawn_student_prop)

	qte.correct_key_pressed.connect(_on_qte_correct_key_pressed)
	qte.wrong_key_pressed.connect(_on_qte_wrong_key_pressed)

	reaction_c2d.hide_c2d()

	world.add_child(bldg_group)
	characters.add_child(obstacle_group)
	characters.add_child(student_props_group)
	obstacles.shuffle()
	student_props.shuffle()

	_spawn_sections()


func start():
	if not _game_started:
		_game_started = true
		_goto_next_obstacle()
		_goto_next_student_prop()


func _spawn_sections():
	for i in range(BLDG_COUNT):
		var bldg = RepeatingSection.instantiate()
		bldg.transform.origin = Vector3(1, 0, 0) * BLDG_OFFSET_X * i

		_bldg_queue.append(bldg)
		bldg_group.add_child(bldg)


func _goto_next_obstacle():
	_obstacle_idx += 1

	if _obstacle_idx >= obstacles.size():
		game_finished.emit()
	else:
		var pre_obstacle_short = pre_obstacle_shorts[_obstacle_idx]
		if pre_obstacle_short != "":
			var short_id = short_path + pre_obstacle_short
			await Story.start_short(short_id)

		var interval = randf_range(obstacle_interval_min, obstacle_interval_max)
		timer_obstacle.start(interval)


func _goto_next_student_prop():
	var interval = randf_range(student_prop_interval_min, student_prop_interval_max)
	timer_prop.start(interval)
	_student_walk_speed = randf_range(0.5, 1)


func _spawn_obstacle():
	var obstacle_prefab = obstacles[_obstacle_idx]
	var obstacle = obstacle_prefab.instantiate()
	_current_obstacle = obstacle

	obstacle.entered.connect(_on_qte_entered)

	obstacle_group.add_child(obstacle)
	obstacle.global_transform.origin = Vector3(-5, 0, 0.45)


func _spawn_student_prop():
	var rand_idx = randi() % student_props.size()
	var student = student_props[rand_idx].instantiate()

	student_props_group.add_child(student)
	student.global_transform.origin = Vector3(-5, 0, 0.3)

	_goto_next_student_prop()


func _process(delta):
	if not _pause_scroll:
		_scroll(delta)


func _scroll(delta):
	var x0 = bldg_group.transform.origin.x
	var x1 = x0 + delta * scroll_speed
	bldg_group.transform.origin.x = fmod(x1, -BLDG_OFFSET_X)

	obstacle_group.translate(Vector3.RIGHT * delta * scroll_speed)
	student_props_group.translate(Vector3.RIGHT * delta * (scroll_speed + _student_walk_speed))


func _on_qte_entered(npc):
	qte.run(npc, qte_time_scale)


func _on_qte_correct_key_pressed():
	_interact_obstacle(true)


func _on_qte_wrong_key_pressed():
	_interact_obstacle(false)


func _interact_obstacle(dodge: bool):
	var obstacle = _current_obstacle

	if not dodge:
		obstacle.sprite.animation = "miss"

	var audio_stream = obstacle.reaction_sfx_dodge if dodge else obstacle.reaction_sfx_miss
	var c2d = obstacle.reaction_dodge if dodge else obstacle.reaction_miss
	var short_knot: String = obstacle.short_knot_dodge if dodge else obstacle.short_knot_miss

	if audio_stream != null:
		reaction_sfx.stream = audio_stream
		reaction_sfx.play()

	if c2d != null:
		reaction_c2d.show_c2d(c2d, obstacle.pan_direction)
		_pause_scroll = true

		obstacle.global_transform.origin.x = player.global_transform.origin.x

		await Utils.wait(c2d_reaction_show_duration, true)

		if not dodge:
			mark_tripped.emit()

		reaction_c2d.visible = false
		_pause_scroll = false

	if short_knot.length() > 0:
		var short_id = short_path + short_knot
		await Story.start_short(short_id)

	_goto_next_obstacle()
