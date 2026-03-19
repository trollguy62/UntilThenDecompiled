extends Sprite2D

@export var mask: SubViewport
@export var tree: Sprite2D
@export var enabled = false:
	set(value):
		enabled = value
		create_tween().tween_property(self, "modulate:a",
				1 if enabled else 0, 1.0)

@onready var bark_chippings = $BarkChippings
@onready var sfx_tree_carving = $SfxTreeCarving

var target_global_rotation: float = global_rotation
var active_carving_time : float
var carving_time_for_ach: float = 15
var is_prospero = false

func _ready():
	self.enabled = false
	_set_carving(false)
	active_carving_time = 0
	is_prospero = OS.get_name() == "Prospero"

func _input(event: InputEvent):
	var carving = false

	if enabled and is_visible_in_tree() and event is InputEventMouseMotion:
		var old_global_pos = global_position
		global_position = event.global_position / Vector2(get_window().size) * Vector2(1280, 720)
		target_global_rotation = global_position.angle_to_point(old_global_pos)
		
		if is_prospero:
			carving = Input.get_action_strength("c_interact") > 0 and \
					tree.is_pixel_opaque(global_position / tree.scale)
		else:
			carving = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and \
					tree.is_pixel_opaque(global_position / tree.scale)

	if is_prospero:
		if (enabled and event is InputEventMouseMotion) or not enabled:
			_set_carving(carving)
	else:
		_set_carving(carving)

func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("c_move_right") - Input.get_action_strength("c_move_left"),
		Input.get_action_strength("c_move_down") - Input.get_action_strength("c_move_up")
	)

func _process(delta: float):
	if not is_visible_in_tree():
		return

	global_rotation = lerp(global_rotation, target_global_rotation, 0.05)
	
	if is_prospero and enabled:
		var input_v = _get_input()
			
		var event = InputEventMouseMotion.new()

		var sensitivity = 600.0
		var vp = get_viewport()
		var to_mouse_pos: Vector2 = vp.get_mouse_position() + input_v * sensitivity * delta

		var vp_visible_rect = vp.get_visible_rect()
		to_mouse_pos.x = clamp(to_mouse_pos.x, 0, vp_visible_rect.size.x)
		to_mouse_pos.y = clamp(to_mouse_pos.y, 0, vp_visible_rect.size.y)
		
		event.global_position = to_mouse_pos * 2
		_input(event)


func _set_carving(carving: bool):
	bark_chippings.emitting = carving
	mask.carving = carving
	sfx_tree_carving.playing = carving

	if carving:
		active_carving_time += get_process_delta_time()

func _on_minigame_finished():
	if active_carving_time >= carving_time_for_ach:
		Game.dist_platform.unlock_achievement("ACH_CARVE_CRAZY")
