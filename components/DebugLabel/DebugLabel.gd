extends Label

### Command handler ###
var _command_handler = _run_command

@onready var tween = Threen.new()

func _ready():
	add_child(tween)

func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	if cmd.name == "debuglabel.print":
		text = cmd.params[0]
		tween.interpolate_property(self, "modulate", Color.RED, Color.WHITE, 1.0)
		tween.start()
		return null
	else:
		return Constants.CMD_RETURN_NONE
