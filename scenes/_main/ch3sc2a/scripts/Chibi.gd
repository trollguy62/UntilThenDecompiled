extends Sprite2D

@export var alias := ""
@export var active_color := Color.GREEN
@export var inactive_color := Color.WHITE

@onready var sprite = $AnimatedSprite
@onready var tween = Threen.new()

@onready var _initial_y = position.y

var _shake_t := 999.0


func _ready():
	add_child(tween)
	if alias == "":
		alias = name

	self_modulate = inactive_color


func _process(delta: float):
	_shake_t += delta
	position.y = _initial_y + Utils.spring(_shake_t, 8, 0.75, 16)


func set_active(active: bool):
	var c0 = self_modulate
	var c1 = active_color if active else inactive_color
	tween.interpolate_property(self, "self_modulate", c0, c1, 1.0)
	tween.start()


func shake():
	_shake_t = 0.0


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	if not is_visible_in_tree() or params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"chibi.set_anim":
			sprite.animation = params[1]
		"chibi.set_active":
			set_active(bool(params[1]))
		"chibi.shake":
			shake()
		_:
			return Constants.CMD_RETURN_NONE

	return null
