extends Node2D

signal interacted
signal minigame_finished

const State = preload("res://data/State.gd")

@onready var usb = $USB
@onready var interactive = $Interactive
@onready var control_hint_anim_player = $ControlHint/AnimationPlayer

var can_plug = false
var _state: SelfState


func _ready():
	_set_state(PlugState.new(self, 0))
	usb.port_entered.connect(_on_port_entered)
	usb.port_exited.connect(_on_port_exited)
	interactive.pressed.connect(_interact_if_can_plug)

func _process(delta):
	if not is_visible_in_tree():
		return

	if Input.is_action_just_pressed("interact"):
		_interact_if_can_plug()

	var next_state = _state._process(delta)
	if next_state:
		_set_state(next_state)


func present_control_hint():
	control_hint_anim_player.play("present")


func _interact_if_can_plug():
	if can_plug:
		interacted.emit()


func _set_state(next_state: SelfState):
	if _state:
		_state.exit()
	_state = next_state
	_state.enter()


func _on_port_entered():
	can_plug = true
	_state._on_port_entered()


func _on_port_exited():
	can_plug = false
	_state._on_port_exited()


class SelfState:
	extends State
	var host: Node2D
	var step: int

	func _init(host: Node2D, step: int):
		self.host = host
		self.step = step

	func _on_port_entered():
		pass

	func _on_port_exited():
		pass


class PlugState:
	extends SelfState
	var next := false

	func _init(host: Node2D, step: int):
		super(host,step)
		pass


	func enter():
		host.interacted.connect(_on_interacted)

		if host.can_plug:
			_on_port_entered()
		else:
			_on_port_exited()

	func exit():
		host.interacted.disconnect(_on_interacted)

	func _process(_delta):
		if next:
			return PluggingState.new(host, step, step == 2)

	func _on_port_entered():
		host.interactive.icon = "plug"

	func _on_port_exited():
		host.interactive.icon = ""

	func _on_interacted():
		next = true


class PluggingState:
	extends SelfState
	var next_state: SelfState
	var successful: bool

	func _init(host: Node2D, step: int, successful: bool):
		super(host,step)
		self.successful = successful

	func enter():
		host.usb.plug_finished.connect(_on_plug_finished)
		host.usb.plug_failed.connect(_on_plug_failed)
		host.usb.plug(successful)
		host.interactive.icon = ""

	func exit():
		host.usb.plug_finished.disconnect(_on_plug_finished)
		host.usb.plug_failed.disconnect(_on_plug_failed)

	func _process(_delta):
		if next_state:
			return next_state

	func _on_plug_finished():
		next_state = DoneState.new(host, step)

	func _on_plug_failed():
		next_state = FlipState.new(host, step)


class FlipState:
	extends SelfState
	var next := false

	func _init(host: Node2D, step: int):
		super(host,step)

	func enter():
		host.interacted.connect(_on_interacted)
		host.interactive.icon = "flip"

	func exit():
		host.interacted.disconnect(_on_interacted)

	func _process(_delta):
		if next:
			return PlugState.new(host, step + 1)

	func _on_interacted():
		host.interactive.icon = ""
		host.usb.flip()

		await host.usb.flip_finished
		next = true


class DoneState:
	extends SelfState

	func _init(host: Node2D, step: int):
		super(host,step)

	func enter():
		host.minigame_finished.emit()
