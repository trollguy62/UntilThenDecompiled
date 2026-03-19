extends Sprite2D

signal reveal_finish
signal select(cup)

@onready var tween = Threen.new()
@onready var area = $Area2D
@onready var collider = $Area2D/CollisionShape2D
@onready var cup_illuminated = $CupIlluminated

@onready var sfx_cup_close = $SfxCupClose
@onready var sfx_cup_open = $SfxCupOpen

var horizontal_distance: float
var swap_speed: float
var focused_color: Color
var open_close_duration: float
var initial_show_delay_duration: float
var swap_y_trans_peak: float
var default_pos: Vector2

var _swap_y_process := false
var _swap_y_base := 0.0
var _swap_y_t := 0.0
var _swap_y_up := false


func _ready():
	add_child(tween)
	default_pos = position
	cup_illuminated.modulate = Color.TRANSPARENT


func _process(delta):
	if _swap_y_process:
		var dy = 1 - pow(2 * _swap_y_t - 1, 2)
		dy *= swap_y_trans_peak
		dy *= -1 if _swap_y_up else 1
		position.y = _swap_y_base + dy

func move_by(delta_idx: int):
	if delta_idx == 0:
		return

	var x0 = position.x
	var x1 = x0 + horizontal_distance * delta_idx

	tween.interpolate_property(
		self, "position:x", x0, x1, swap_speed, Threen.TRANS_QUAD, Threen.EASE_IN_OUT
	)
	tween.interpolate_property(self, "_swap_y_t", 0.0, 1.0, swap_speed)
	tween.start()

	_swap_y_process = true
	_swap_y_base = position.y
	_swap_y_up = delta_idx > 0

	await tween.tween_all_completed
	_swap_y_process = false



func reveal(emit):
	open()
	await tween.tween_completed

	await Utils.wait(initial_show_delay_duration)
	close()

	await tween.tween_completed

	if emit:
		reveal_finish.emit()


func open():
	sfx_cup_open.play()
	await _translate_y(-50)


func close():
	sfx_cup_close.play()
	await _translate_y(50)


func _translate_y(dy: float):
	var to = position + Vector2(0, dy)
	tween.interpolate_property(
		self, "position", position, to, open_close_duration, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
	)
	tween.start()
	await tween.tween_all_completed

func reset_position():
	position = default_pos


func illuminate(illuminated: bool, has_ball: bool = false):
	var tex_cup_0 = preload("res://scenes/_main/ch3sc2b/MinigameFindTheBall/assets/paper_cup_illuminated.png")
	var tex_cup_1 = preload("res://scenes/_main/ch3sc2b/MinigameFindTheBall/assets/paper_cup_illuminated_ball.png")
	cup_illuminated.texture = tex_cup_1 if has_ball else tex_cup_0

	var c0 = cup_illuminated.modulate
	var c1 = Color.WHITE if illuminated else Color.TRANSPARENT

	if c0 == c1:
		return

	tween.interpolate_property(cup_illuminated, "modulate", c0, c1, 1.0)
	tween.start()
