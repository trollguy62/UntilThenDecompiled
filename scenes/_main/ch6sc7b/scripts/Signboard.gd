extends Node3D

@export var alias: String
@export var content_textures: Array[Texture]
@export var design_textures: Array[Texture]
@export var signboard_pos_y: Array[float]

@onready var content = $Container/Content
@onready var design = $Container/Design
@onready var container = $Container
@onready var sprite = get_parent()


func _ready():
	content.texture = null
	design.texture = null
	visible = false
	sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed():
	if visible:
		container.position.y = signboard_pos_y[sprite.frame]


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	if not (params.size() >= 1 and str(params[0]) == alias):
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_signboard_content":
			content.texture = content_textures[params[1]]
			print("alias: " + str(params[0]) + "  id:" + str(params[1]))
		"set_signboard_design":
			design.texture = design_textures[params[1]]
		"show_signboard":
			visible = params[1]
		_:
			return Constants.CMD_RETURN_NONE
