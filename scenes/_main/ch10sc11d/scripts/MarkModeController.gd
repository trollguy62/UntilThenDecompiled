extends Node

enum TinkeringState { TINKER, OBSERVE, STANDBY, WALK }

@export var laser_pointer : Node
@onready var start = $"../Start"
@onready var end = $"../End"
@onready var state_timer : Timer = $Timer
@onready var sprite = $Sprite
@onready var state_container: StateContainer = Utils.get_state_container_of(sprite.alias)
@onready var grounder = $PathGrounder

var tinkering_state = TinkeringState.TINKER
var next_state = []
var current_mode
var change_state_interval = 4

func _ready():
	state_timer.timeout.connect(_on_timer_timeout)


func _process(delta):
	var mode = state_container.dict.get_value("mode", "tinkering")

	if current_mode == mode:
		return

	if mode == "tinkering":
		current_mode = mode
		tinkering_state = TinkeringState.TINKER
		tinkering()
	elif mode == "controlled":
		current_mode = mode
		controlled()
	elif mode == "toggling_laser":
		current_mode = mode
		toggling_laser()


func tinkering():
	laser_pointer.visible = true

	match tinkering_state:
		TinkeringState.TINKER:
			next_state = [TinkeringState.OBSERVE, TinkeringState.STANDBY]
			set_animation("tinkering")
		TinkeringState.OBSERVE:
			next_state = [TinkeringState.TINKER, TinkeringState.STANDBY]
			set_animation("observe")
		TinkeringState.STANDBY:
			next_state = [TinkeringState.WALK,TinkeringState.TINKER]
			set_animation("X")
		TinkeringState.WALK:
			await walk()
			if(current_mode != "tinkering"):
				return
			next_state = [TinkeringState.OBSERVE, TinkeringState.TINKER]
			set_animation("X")


func controlled():
	state_timer.stop()
	await move_to_laser()
	state_container.dict.set_value("with", "X")
	laser_pointer.visible = true

func toggling_laser():
	state_timer.stop()
	await move_to_laser()
	state_container.dict.set_value("with", "laser")
	laser_pointer.visible = false


func set_state():
	tinkering_state = next_state[randi() % next_state.size()]

func _on_timer_timeout():
	set_state()
	tinkering()

func set_animation(anim):
	state_container.dict.set_value("with", anim)
	state_timer.start(change_state_interval)
	state_timer.one_shot = true


func walk():
	await set_target_pos(end.global_transform.origin, false)

	if(current_mode != "tinkering"):
		return

	state_container.dict.set_value("with", "X")
	await get_tree().create_timer(4.0).timeout

	if(current_mode != "tinkering"):
		return

	await set_target_pos(start.global_transform.origin, true)
	sprite.flip_h = false

func move_to_box():
	pass

func move_to_laser():
	await set_target_pos(start.global_transform.origin, true)
	sprite.flip_h = false

func set_target_pos(pos, flip):
	grounder.set_target_pos(pos, 0.5)
	sprite.flip_h = flip
	state_container.dict.set_value("with", "walk")
	await grounder.target_reached
