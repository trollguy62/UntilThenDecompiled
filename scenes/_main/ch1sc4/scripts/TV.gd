@tool
extends Sprite3D

@export var slides: Array[Texture]
@export var slide_idx: int = 0:
	set(value):
		slide_idx = value
		var slide = Utils.array_get(slides, slide_idx)
		var material = material_override as ShaderMaterial
		material.set_shader_parameter("texture_emission", slide)

func _ready():
	self.slide_idx = slide_idx


### Command handler ###
func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_run_command)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	if cmd.name == "set_tv_slide_idx":
		self.slide_idx = cmd.params[0]
		return null
	return Constants.CMD_RETURN_NONE
