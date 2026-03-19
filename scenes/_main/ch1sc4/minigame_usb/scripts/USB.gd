extends Node2D

signal port_entered
signal port_exited
signal flip_finished
signal plug_finished
signal plug_failed

const State = preload("res://data/State.gd")

const PLUG_X_SUCCESS = 612
const PLUG_X_FAIL = 716

@onready var tween = Threen.new()
@onready var plug_fail = $PlugFail
@onready var plug_success = $PlugSuccess
@onready var flip_sfx = $Flip
@onready var sprite = $Sprite
@onready var hint = $Hint
@onready var area = $Area2D

var flipped = false
var _state: SelfState


func _ready():
	add_child(tween)
	_set_state(FreeState.new(self))
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func _set_state(new_state: SelfState):
	if _state:
		_state.exit()
	_state = new_state
	_state.enter()


func _process(delta):
	if not is_visible_in_tree():
		return

	var next_state = _state._process(delta)
	if next_state:
		_set_state(next_state)


func _on_area_entered(_area):
	port_entered.emit()


func _on_area_exited(_area):
	port_exited.emit()


func _play_block_hint():
	hint.play("default")
	await get_tree().process_frame
	hint.play("block")


func is_free() -> bool:
	return _state is FreeState


func plug(successful: bool):
	if is_free():
		_state.plug(successful)


func flip():
	if is_free():
		_state.flip()


class SelfState:
	extends State
	var host: Node2D

	func _init(host: Node2D):
		self.host = host


class FreeState:
	extends SelfState
	var next_state: SelfState
	var last_mouse_pos: float = 0.0

	func _init(host: Node2D):
		super(host)
		last_mouse_pos = host.get_global_mouse_position().y

	func _process(_delta):
		if next_state:
			return next_state
		get_movement(host)

	func plug(successful: bool):
		next_state = PluggingState.new(host, successful)

	func flip():
		next_state = FlippingState.new(host)

	func get_movement(host):
		var input_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		var cur_mouse_pos = host.get_global_mouse_position().y
		var sensitivity = 20.0

		host.global_position.y += sensitivity * input_y

		if cur_mouse_pos != last_mouse_pos:
			if cur_mouse_pos > 0 and cur_mouse_pos < DisplayServer.window_get_size().y:
				host.global_position.y = cur_mouse_pos

		last_mouse_pos = cur_mouse_pos

	func _input(ev):
		assert(false)


class FlippingState:
	extends SelfState
	var next_state: SelfState

	func _init(host: Node2D):
		super(host)


	func enter():
		var trans_anim = "b_to_a" if host.flipped else "a_to_b"
		var dest_anim = "side_a" if host.flipped else "side_b"

		host.flip_sfx.play()
		host.flipped = not host.flipped
		host.sprite.play(trans_anim)

		await host.sprite.animation_finished

		host.sprite.play(dest_anim)
		host.flip_finished.emit()

		next_state = FreeState.new(host)

	func _process(delta):
		return next_state


class PluggingState:
	extends SelfState
	var successful: bool
	var next_state: SelfState

	func _init(host: Node2D, successful: bool):
		super(host)
		self.successful = successful

	func enter():
		var tween: Threen = host.tween
		var target_x = PLUG_X_SUCCESS if successful else PLUG_X_FAIL
		var pos = [host.position, Vector2(target_x, host.position.y)]
		var dur = 0.0035 * abs(target_x - host.position.x)

		tween.interpolate_property(
			host, "position", pos[0], pos[1], dur, Threen.TRANS_CUBIC, Threen.EASE_OUT
		)
		tween.start()

		if successful:
			host.plug_success.play()
		else:
			host.plug_fail.play()

		await tween.tween_completed
		if successful:
			next_state = PluggedState.new(host)
			host.plug_finished.emit()
			return

		host._play_block_hint()
		tween.interpolate_property(
			host, "position", pos[1], pos[0], dur, Threen.TRANS_CUBIC, Threen.EASE_IN
		)
		tween.start()

		await tween.tween_completed
		next_state = FreeState.new(host)
		host.plug_failed.emit()

	func _process(_delta):
		return next_state


class PluggedState:
	extends SelfState

	func _init(host: Node2D):
		super(host)
