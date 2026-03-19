extends Node2D

signal tempo_updated(tempo)

@onready var sliding_weight = $Path2D/PathFollow2D/SlidingWeight
@onready var path_follow = $Path2D/PathFollow2D
@onready var collision = $Path2D/PathFollow2D/SlidingWeight/CollisionShape2D
@onready var path = $Path2D
@onready var tween = Threen.new()
@onready var beat = $Beat
@onready var beat_emphasis = $BeatEmphasis
@onready var anim_player = $AnimationPlayer
var offset = Vector2(0, -20)
var allow_drag
var dragging = false
var last_tempo = 0
var min_tempo = 40
var max_tempo = 208
var current_tempo = min_tempo
var min_angle = -45
var max_angle = 45
var playing = false
var beat_measure = 2
var beat_count = 0

#exposed vars for syncing with the rhythm minigame
var time_to_next_beat_ms: float = 0 : get = get_time_to_next_beat_ms


func get_time_to_next_beat_ms():
	var half_period = 60.0 / current_tempo
	return half_period - fmod(_t, half_period)


var beats_to_next_emphasis: float = 0 : get = get_beats_to_next_emphasis


func get_beats_to_next_emphasis():
	return beat_measure - beat_count - 1


#

var _t := 0.0


func _ready():
	add_child(tween)
	sliding_weight.mouse_entered.connect(_on_mouse_entered)
	sliding_weight.mouse_exited.connect(_on_mouse_exited)


func _process(delta):
	if dragging:
		path_follow.progress = path.curve.get_closest_offset(
			get_viewport().get_mouse_position() + offset
		)

	set_tempo()

	if playing:
		swing_pendulum(delta)
	else:
		reset_pendulum_rotation(delta)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and allow_drag:
				dragging = true
			else:
				dragging = false


func _on_mouse_entered():
	allow_drag = true


func _on_mouse_exited():
	allow_drag = false


func start_swing():
	_t = 0
	beat_count = 0
	playing = true
	anim_player.play("RESET")

func set_beat_measure(beat_measure):
	self.beat_measure = beat_measure


func stop_swing():
	playing = false
	anim_player.play("fade_out_vol")

func fade_out_vol():
	anim_player.play("fade_out_vol")

func fade_in_vol():
	anim_player.play("fade_out_vol", -1, -1.0, true)

func swing_pendulum(delta):
	var last_t = _t
	_t += delta

	var half_period = 60.0 / current_tempo
	var freq = current_tempo / 60.0 * PI
	rotation_degrees = sin_bounded(_t, min_angle, max_angle, freq)

	if floor(last_t / half_period) < floor(_t / half_period):
		play_beat()


func reset_pendulum_rotation(delta):
	var speed = (current_tempo * PI) / 60
	rotation = lerp_angle(deg_to_rad(rotation_degrees), deg_to_rad(0), speed * delta)


func play_beat():
	beat_count += 1

	if beat_count < beat_measure:
		beat.play()
	else:
		beat_emphasis.play()
		beat_count = 0


func set_tempo():
	current_tempo = (max_tempo - min_tempo) * pow(path_follow.progress_ratio, 1.1) + 40
	current_tempo = int(round(current_tempo))

	_t *= float(last_tempo) / float(current_tempo)

	if current_tempo != last_tempo:
		last_tempo = current_tempo
		tempo_updated.emit(current_tempo)


func sin_bounded(x: float, a: float, b: float = 0, t: float = 1) -> float:
	var n = (b - a) / 2
	return (n * sin(t * x)) + n + a
