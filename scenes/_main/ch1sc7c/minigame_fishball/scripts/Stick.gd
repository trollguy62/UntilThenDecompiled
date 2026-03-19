extends CharacterBody2D

signal turn_started
signal aim_position_started
signal aim_position_finished
signal aim_strength_started
signal aim_strength_finished
signal attack_started
signal attack_finished(fishball_count)
signal turn_finished

const State = preload("res://data/State.gd")
const Fishball = preload("Fishball.gd")

const X_MIN = 294
const X_MAX = 1018
const Y_HIDDEN = -32
const Y_NORMAL = 200
const Y_ATTACK = 420

@export var stick_move_speed = 2.5
@export var atk_strength_ind_speed = 4.0

@onready var tween = Threen.new()
@onready var collider = $CollisionShape2D
@onready var area = $Area2D
@onready var input_controller = $InputController
@onready var atk_strength_bar = $AtkStrengthBar
@onready var atk_strength_indicator = $AtkStrengthBar/Indicator

var _state: SelfState
var t := 0.0
var atk_strength := 0.0


func _ready():
	add_child(tween)
	_set_state(HiddenState.new(self))
	collider.disabled = false
	atk_strength_bar.visible = false


func _process(delta):
	t += delta
	var new_state = _state._process(delta)
	if new_state:
		_set_state(new_state)


func _process_position():
	var x = Utils.sin_bounded(t, X_MIN, X_MAX, stick_move_speed)
	position.x = x


func _process_atk_strength():
	var k = sin(t * atk_strength_ind_speed)
	atk_strength = 1 - abs(k)
	var ix = Utils.remap(-1, 1, 1, 38, k)
	atk_strength_indicator.position.x = ix


func _set_state(new_state: SelfState):
	if _state:
		_state.exit()
	_state = new_state
	_state.enter()


func set_y(
	y: float, duration: float, trans_type: int = Threen.TRANS_LINEAR, ease_type: int = Threen.EASE_IN
):
	var py = [position.y, y]
	tween.stop_all()
	tween.interpolate_method(self, "_set_y_pos", py[0], py[1], duration, trans_type, ease_type)
	tween.start()
	await tween.tween_completed

func _set_y_pos(y: float):
	position.y = y


func start_turn():
	if _state is HiddenState:
		_state.start_aim()


class SelfState:
	extends State
	var host

	func _init(host):
		self.host = host

	func is_input_just_pressed() -> bool:
		return host.input_controller.is_just_pressed()


class HiddenState:
	extends SelfState
	var next_state: SelfState

	func _init(host):
		super(host)

	func enter():
		host.visible = false
		host.position.y = Y_HIDDEN

	func _process(_delta):
		return next_state

	func start_aim():
		next_state = AimPositionState.new(host)

	func exit():
		host.visible = true


class AimPositionState:
	extends SelfState
	var aiming = false

	func _init(host):
		super(host)

	func enter():
		host.turn_started.emit()
		await host.set_y(Y_NORMAL, 0.5)
		aiming = true
		host.aim_position_started.emit()

	func _process(delta):
		host._process_position()
		if aiming and is_input_just_pressed():
			host.aim_position_finished.emit()
			return AimStrengthState.new(host)


class AimStrengthState:
	extends SelfState
	var next = false
	var timer = Timer.new()

	func _init(host):
		super(host)
		timer.one_shot = true

	func enter():
		timer.timeout.connect(_on_timeout)
		host.add_child(timer)
		host.atk_strength_bar.visible = true
		host.aim_strength_started.emit()

	func _on_timeout():
		next = true

	func _process(delta):
		if next:
			var sticky = host.atk_strength > 0.65
			return AttackState.new(host, sticky)
		if timer.time_left > 0:
			return

		host._process_atk_strength()
		if is_input_just_pressed():
			host.aim_strength_finished.emit()
			timer.start(0.5)

	func exit():
		timer.queue_free()
		host.atk_strength_bar.visible = false


class AttackState:
	extends SelfState
	var sticky: bool
	var next_state: SelfState
	var fishballs := []

	func _init(host, sticky: bool):
		super(host)
		self.sticky = sticky

	func enter():
		host.attack_started.emit()
		var collider: CollisionShape2D = host.collider
		collider.disabled = sticky

		var dur = lerp(1.0, 0.3, host.atk_strength)
		await host.set_y(Y_ATTACK, dur, Threen.TRANS_QUAD, Threen.EASE_OUT)


		if sticky:
			_stick()
		await Utils.wait(0.5)
		host.attack_finished.emit(fishballs.size())

		await host.set_y(Y_HIDDEN, 1.5, Threen.TRANS_QUAD, Threen.EASE_IN)

		host.turn_finished.emit()

		next_state = HiddenState.new(host)

	func _process(_delta):
		return next_state

	func exit():
		host.collider.disabled = false
		for fishball in fishballs:
			fishball.queue_free()

	func _stick():
		var area: Area2D = host.area
		for overlapping_area in area.get_overlapping_areas():
			var fishball = Fishball.get_fishball_of(overlapping_area)
			if fishball is Fishball:
				fishball.stick(host)
				fishballs.append(fishball)
