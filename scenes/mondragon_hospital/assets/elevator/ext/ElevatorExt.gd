extends Node3D

@export_range(0, 3) var floor_idx = 0
@export var display_emission_textures: Array[Texture] = []

@onready var anim_player = $AnimationPlayer
@onready var display = $Display

var display_mat: ShaderMaterial


func _ready():
	display_mat = display.material_override.duplicate()
	display.material_override = display_mat


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var cmd_floor_idx = Utils.array_get(params, 0, -1)

	if not (cmd_floor_idx is int and cmd_floor_idx == floor_idx):
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"elevext.show_display":
			var em_tex = display_emission_textures[floor_idx]
			display_mat.set_shader_parameter("texture_emission", em_tex)
			$SFX/Bell.play()

		"elevext.hide_display":
			display_mat.set_shader_parameter("texture_emission", null)

		"elevext.open":
			anim_player.play("open")
			$SFX/DoorOpening.play()

		"elevext.close":
			anim_player.play_backwards("open")
			$SFX/DoorClosing.play()

		_:
			return Constants.CMD_RETURN_NONE

	return null
