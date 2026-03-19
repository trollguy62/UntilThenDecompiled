extends Node2D

@export var scroll_speed_mult := 1.0:
	set(v):
		scroll_speed_mult = v
		if not is_inside_tree():
			await ready

		ht_spawner.lead_in_time = _get_total_note_lead_in()

const ARROW_ASSETS_PATH = "res://modules/rhythm-minigame/assets/mania/arrows/"
const ARROW_DIRECTIONS = ["left", "down", "up", "right"]

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const HitInput = preload("res://modules/rhythm-minigame/classes/input/HitInput.gd")
const OsuHitObject = preload("res://modules/rhythm-minigame/classes/beatmap/OsuHitObject.gd")

const COLUMN_COUNT: int = 4
const PERFECT_SCORE_MULT: float = 1.0
const GREAT_SCORE_MULT: float = 0.8
const MISS_SCORE_MULT: float = 0.0

var timestamp_msec: int = 0
var is_playing = false
var hit_objects: Array
var is_simulation = false
var last_score: float = 0: get = get_last_playthrough_score #returns a value between 0-1

var flag_unfinished_last_play = false
var controller_textures: Array = [null, null, null, null]

var _unjudged_hit_objects: Array
var _simulation_hit_objects: Array

@onready var arrow_frame := $ArrowFrame
@onready var ht_spawner := $HitTargetSpawner
@onready var judgment_text := $JudgmentText
@onready var labels: Dictionary = {
	"combo": $CanvasLayer/Control/VBoxContainer/Combo,
	"perfect": $CanvasLayer/Control/VBoxContainer/Perfect,
	"great": $CanvasLayer/Control/VBoxContainer/Great,
	"miss": $CanvasLayer/Control/VBoxContainer/Miss,
}
@onready var dci =  $DummyControllerTextures.get_children()

var arrow_textures: Dictionary = {"filled": [], "unfilled": []}

var combo: int = 0:
	set(v):
		combo = v
		labels["combo"].text = str(combo) + " Combo"


var perfect_count: int = 0:
	set(v):
		perfect_count = v
		labels["perfect"].text = "Perfect: " + str(perfect_count)


var great_count: int = 0:
	set(v):
		great_count = v
		labels["great"].text = "Great: " + str(great_count)


var miss_count: int = 0:
	set(v):
		miss_count = v
		labels["miss"].text = "Miss: " + str(miss_count)


func _ready():
	_load_textures()
	
	_on_input_type_changed(ControllerIcons._last_input_type)
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)

	$HitTargetSpawner.arrow_frame = $ArrowFrame
	ht_spawner.column_height = arrow_frame.position.y - ht_spawner.position.y
	arrow_frame.input_triggered.connect(_on_input_triggered)
	ht_spawner.new_result.connect(_on_new_hit_result)


func _process(delta):
	if !is_playing:
		return

	for i in dci.size():
		controller_textures[i] = dci[i].texture
		if ControllerIcons._last_input_type == ControllerIcons.InputType.CONTROLLER:
			arrow_frame.controller_textures = controller_textures
			arrow_frame.use_controller_textures = true
			ht_spawner.left_texture = controller_textures[0]
			ht_spawner.down_texture = controller_textures[1]
			ht_spawner.up_texture = controller_textures[2]
			ht_spawner.right_texture = controller_textures[3]

	var ms: float = timestamp_msec + _get_total_note_lead_in()

	while hit_objects.size() > 0 and ms >= hit_objects.front().time:
		var ho: OsuHitObject = hit_objects.pop_front()
		var dt: float = ms - ho.time

		if dt > 200.0:
			print("Mania: Hit object at time %d ignored" % ho.time)
		else:
			ht_spawner.spawn(ho)

	if hit_objects.size() <= 0:
		is_playing = false

	if is_simulation:
		_simulate_autoplay()

func _on_input_type_changed(input_type: ControllerIcons.InputType):
	var is_controller = input_type == ControllerIcons.InputType.CONTROLLER
	arrow_frame.use_controller_textures = is_controller
	
	if is_controller:
		ht_spawner.left_texture = controller_textures[0]
		ht_spawner.down_texture = controller_textures[1]
		ht_spawner.up_texture = controller_textures[2]
		ht_spawner.right_texture = controller_textures[3]
	else:
		ht_spawner.left_texture = arrow_textures["filled"][0]
		ht_spawner.down_texture = arrow_textures["filled"][1]
		ht_spawner.up_texture = arrow_textures["filled"][2]
		ht_spawner.right_texture = arrow_textures["filled"][3]


func start(autoplay = false):
	is_playing = true
	flag_unfinished_last_play = false
	if autoplay:
		_simulation_hit_objects = hit_objects.duplicate()

	is_simulation = autoplay

	self.combo = 0
	self.perfect_count = 0
	self.great_count = 0
	self.miss_count = 0

	ht_spawner.lead_in_time = _get_total_note_lead_in()

func stop():
	is_playing = false
	flag_unfinished_last_play = true


func get_last_playthrough_score():
	if is_playing or flag_unfinished_last_play:
		printerr("returning last valid score")
		return last_score



	var max_possible_score = (
		PERFECT_SCORE_MULT
		* (self.perfect_count + self.great_count + self.miss_count)
	)

	if max_possible_score <= 0:
		return 0

	last_score = (
		(
			self.perfect_count * PERFECT_SCORE_MULT
			+ self.great_count * GREAT_SCORE_MULT
			+ self.miss_count * MISS_SCORE_MULT
		)
		/ max_possible_score
	)

	return last_score

func is_score_perfect():
	if self.perfect_count > 0 and self.great_count == 0 and self.miss_count == 0 and self.combo > 0:
		return true

	return false


func _load_textures():
	for dir in ARROW_DIRECTIONS:
		for texture_type in arrow_textures.keys():
			var fpath = "arrow_" + texture_type + "_" + dir + ".png"
			var final_path = ARROW_ASSETS_PATH + fpath
			assert(FileAccess.file_exists(final_path))
			var texture: Texture = load(final_path)
			assert(texture)
			arrow_textures[texture_type].append(texture)

	arrow_frame.arrow_textures = arrow_textures
	arrow_frame.controller_textures = controller_textures

func _get_total_note_lead_in() -> float:
	return 1000.0 * (1.0 / scroll_speed_mult)


func _simulate_autoplay():
	while (
		_simulation_hit_objects.size() > 0
		&& timestamp_msec >= _simulation_hit_objects.front().time
	):
		var current: OsuHitObject = _simulation_hit_objects.pop_front()
		arrow_frame._trigger(current.column, true)


func _on_input_triggered(column: int, state: bool):
	var hi: HitInput = HitInput.new(timestamp_msec, column, state)
	ht_spawner.handle(hi)


func _on_new_hit_result(hit_result: HitResult, column):
	match hit_result.type:
		HitResult.HIT_RESULT_PERFECT:
			self.perfect_count += 1
		HitResult.HIT_RESULT_GREAT:
			self.great_count += 1
		HitResult.HIT_RESULT_MISS:
			self.miss_count += 1

	if hit_result.affects_combo:
		self.combo += 1
	else:
		self.combo = 0

	arrow_frame.apply_hit_result(hit_result, column)
