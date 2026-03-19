@tool
extends Node3D

const PLOT_SIZE = 5.0

@export var plot_scene: PackedScene
@export_range(0.0, 8.0) var scroll_speed = 1.0
@export_range(0, 32) var plot_count_cols = 4
@export_range(0, 32) var plot_count_rows = 1
@export_range(0.0, 1.0) var field_coverage = 1.0

@export var scatter_scenes: Array[PackedScene]
@export var sparse_bg_scenes: Array[PackedScene]
@export var ruling_scatter_scenes: Array[PackedScene]

@export var debug_scroll_editor = false

@onready var plot_container = Node3D.new()

var _offset = 0.0
var _k = 0  # running idx
var _last_sparse_spawn = 0


func _ready():
	debug_scroll_editor = false

	add_child(plot_container)

	for i in range(plot_count_cols):
		_make_plot_col(i)


func _make_plot_col(idx: int) -> Node3D:
	var plot_col = Node3D.new()
	plot_container.add_child(plot_col)

	var linear_pos = _get_linear_pos_at(idx)
	plot_col.position.x = linear_pos

	for j in range(plot_count_rows):
		var p = plot_scene.instantiate()
		p.delta_uv = Vector2(idx, -j)
		p.field_coverage = field_coverage

		plot_col.add_child(p)

		p.position.z = -j * PLOT_SIZE
		p.update()

	_populate_plot_col(plot_col)

	return plot_col


func _populate_plot_col(plot_col: Node3D):
	var ruling = field_coverage < 0.5
	var unit_coverage = 4.0 * pow(field_coverage - 0.5, 2.0)
	var max_scatter_count = int((6 if ruling else 4) * unit_coverage)

	for i in range(randi() % (max_scatter_count + 1)):
		var scenes = ruling_scatter_scenes if ruling else scatter_scenes
		var s = _pick_random(scenes).instantiate() as Node3D
		plot_col.add_child(s)

		s.position.x = randf() * PLOT_SIZE - (PLOT_SIZE / 2.0)
		s.position.z = -randf() * (PLOT_SIZE * plot_count_rows - 2.0) + (PLOT_SIZE / 2.0) - 1.0
		s.rotation_degrees.y = 0 if randf() < 0.5 else 180
		s.scale *= randf_range(0.975, 1.025)

	if ruling:
		return

	if randf() < pow(_last_sparse_spawn / plot_count_cols, 2):
		var s = _pick_random(sparse_bg_scenes).instantiate()
		plot_col.add_child(s)

		s.position.z = PLOT_SIZE * (randf() + 0.5 - plot_count_rows)
		s.rotation_degrees.y = 0 if randf() < 0.5 else 180

		_last_sparse_spawn = 0
	else:
		_last_sparse_spawn += 1


func _pick_random(arr: Array):
	return arr[randi() % arr.size()]


func _get_linear_pos_at(idx: int) -> float:
	return (PLOT_SIZE / 2.0) * (2 * idx + 1 - plot_count_cols)


func _process(delta):
	var delta_offset = 0
	if not Engine.is_editor_hint() or debug_scroll_editor:
		delta_offset = scroll_speed * delta

	var vec_offset = Vector3.RIGHT * delta_offset
	_offset += delta_offset

	while _offset > PLOT_SIZE:
		_offset -= PLOT_SIZE
		_k -= 1

		var plot_col: Node3D = plot_container.get_child(plot_count_cols - 1)
		plot_col.queue_free()

		plot_container.move_child(_make_plot_col(_k), 0)

	plot_container.translate(vec_offset)
