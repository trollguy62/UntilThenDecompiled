extends Node2D

@export var alias := ""

@onready var sprite = $Sprite
@onready var tracer = $Tracer
@onready var sfx = $SFX
@onready var pointer

func _ready():
	pointer = get_node_or_null("Pointer")

	if alias == "":
		alias = name

	await get_tree().process_frame
	visible = false

	if pointer != null:
		pointer.visible = false

	Input.joy_connection_changed.connect(_on_joy_connection_changed)

### Command handler ###
var _command_handler = _run_command


func _on_joy_connection_changed(device, connected):
	if not is_visible_in_tree():
		return
	if connected and Input.get_connected_joypads().size() > 0:
		pointer.visible = visible

func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	if params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"trace_stroke":
			visible = true
			if Input.get_connected_joypads().size() > 0:
				pointer.visible = true
			await tracer.trace_finished
			pointer.visible = false
			sfx.play()
		_:
			return Constants.CMD_RETURN_NONE

	return null
