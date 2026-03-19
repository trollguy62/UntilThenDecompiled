extends MeshInstance3D

@export var sequence : Array[Texture] = []
@export var tex_sequence_default: Texture

@onready var tween = Threen.new()
@onready var shader = material_override as ShaderMaterial

var _seq_idx := -1

func _ready():
	add_child(tween)

func show_next_image(duration: float = 2.0):
	var i0 = _seq_idx
	var i1 = _seq_idx + 1

	if i1 >= sequence.size():
		await get_tree().process_frame
		return

	var tex0 = Utils.array_get(sequence, i0, tex_sequence_default)
	var tex1 = Utils.array_get(sequence, i1, tex_sequence_default)

	shader.set_shader_parameter("tex_0", tex0)
	shader.set_shader_parameter("tex_1", tex1)
	shader.set_shader_parameter("tex_w", 0)

	tween.stop_all()
	tween.interpolate_property(shader, "shader_parameter/tex_w", 0.0, 1.0, duration)

	tween.start()
	_seq_idx += 1
	await tween.tween_all_completed


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	match cmd.name:
		"montage_next_image":
			var duration := 2.0

			if params.size() >= 1:
				duration = float(params[0])

			await show_next_image(duration)
		_:
			return Constants.CMD_RETURN_NONE

	return null
