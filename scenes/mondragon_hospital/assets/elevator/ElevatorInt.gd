extends MeshInstance3D

@export var texture_display_up: Texture
@export var texture_display_down: Texture
@export var texture_display_broken: Texture

@export var texture_control_panel_up: Texture
@export var texture_control_panel_down: Texture
@export var texture_control_panel_broken: Texture

@onready var display = $Display
@onready var control_panel = $ControlPanel

@onready var display_mat = display.material_override as ShaderMaterial
@onready var control_panel_mat = control_panel.material_override as ShaderMaterial


func _set_emission_textures(tex_display: Texture, tex_control_panel: Texture):
	display_mat.set_shader_parameter("texture_emission", tex_display)
	control_panel_mat.set_shader_parameter("texture_emission", tex_control_panel)


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"elevint.clear":
			_set_emission_textures(null, null)
		"elevint.up":
			_set_emission_textures(texture_display_up, texture_control_panel_up)
		"elevint.down":
			_set_emission_textures(texture_display_down, texture_control_panel_down)
		"elevint.broken":
			_set_emission_textures(texture_display_broken, texture_control_panel_broken)
		_:
			return Constants.CMD_RETURN_NONE

	return null
