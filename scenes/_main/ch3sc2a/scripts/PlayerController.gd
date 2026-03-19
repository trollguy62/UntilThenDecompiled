extends Node

const PlayerTarget = preload("res://components/PlayerTarget.gd")
const INPUT_THRESHOLD = 0.5

@export var move_speed := 1.0
@export var flip_h := false
@export var avoid_disabling_collider := false

@export var nonlinear := false
@export var nonlinear_right := Vector3.RIGHT

@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../Sprite/SpriteController"
@onready var grounder = $"../PathGrounder"
@onready var collider = $"../Area/CollisionShape" as CollisionShape3D

@onready var focus = $Focus
@onready var footsteps = $Footsteps

@onready var player_target: PlayerTarget = Service.of("PlayerTarget")
@onready var state_container = Utils.get_state_container_of(sprite_controller.state_container_alias) as StateContainer

var _input_move_dir := 0
var _actual_move_dir := 0


func _ready():
	if player_target != null:
		player_target.changed.connect(_on_player_target_changed)

	grounder.target_reached.connect(_on_path_grounder_target_reached)


func _get_move_dir(move_right: bool):
	var dir = 1 if move_right else -1

	if not nonlinear:
		return dir

	var doffset = dir * (1.0 / 60)
	var dpos = grounder.test_delta_global_position(doffset)
	var nonlinear_dir = nonlinear_right

	if not move_right:
		nonlinear_dir = Vector3.ZERO - nonlinear_right

	if nonlinear_dir.dot(dpos) <= 0:
		dir *= -1

	return dir


func _process(delta):
	var is_active = _is_active()
	var is_walking = false
	var old_input_move_dir = _input_move_dir

	_input_move_dir = 0
	# TODO: Why disable in the first place though?? That doesn't seem right
	collider.disabled = not is_active and not avoid_disabling_collider

	if _is_active() and not grounder.has_target():
		var axis_x: float = Input.get_axis("move_left", "move_right")

		if abs(axis_x) > INPUT_THRESHOLD:
			_input_move_dir = int(sign(axis_x))

	if old_input_move_dir != _input_move_dir:
		if _input_move_dir == 0:
			_actual_move_dir = 0
		else:
			_actual_move_dir = _get_move_dir(_input_move_dir == 1)

	grounder.offset_speed = move_speed * _actual_move_dir

	if abs(grounder.delta_offset) > 0:
		is_walking = true

		if nonlinear:
			sprite.flip_h = nonlinear_right.dot(grounder.delta_global_position) > 0
		else:
			sprite.flip_h = grounder.delta_offset > 0

		if flip_h:
			sprite.flip_h = not sprite.flip_h

	if footsteps:
		if is_walking and sprite.is_visible_in_tree():
			if not footsteps.playing:
				footsteps.play()
		else:
			footsteps.stop()

	if sprite.is_visible_in_tree():
		if is_walking:
			state_container.flags.add("$walk")
		else:
			state_container.flags.remove("$walk")


func _is_active() -> bool:
	return focus.active and sprite.is_visible_in_tree()


func _on_player_target_changed():
	if sprite.is_visible_in_tree():
		var pos = player_target.global_transform.origin
		grounder.set_target_pos(pos, move_speed)


func _on_path_grounder_target_reached():
	Story.emit("_player_target_reached")
