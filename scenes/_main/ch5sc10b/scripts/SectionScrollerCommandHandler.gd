extends Node

@onready var scroller = get_parent()
@onready var tween = Threen.new()


func _ready():
	add_child(tween)


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	if not scroller.is_visible_in_tree() or not scroller.enabled:
		return Constants.CMD_RETURN_NONE

	var params = cmd.params

	match cmd.name:
		"scroller.set_speed":
			var speed = float(params[0])
			var duration = float(Utils.array_get(params, 1, 0))
			var no_wait = cmd.flags.has("no-wait")

			if duration <= Constants.EPSILON:
				scroller.speed = speed
			else:
				tween.interpolate_property(scroller, "speed", scroller.speed, speed, duration)
				tween.start()

				if not no_wait:
					await tween.tween_completed

		"scroller.enqueue_special":
			var idx = int(params[0])
			scroller.enqueue_special_section(idx)

		"scroller.spawn":
			var key = str(params[0])
			scroller.spawn(key)

		_:
			return Constants.CMD_RETURN_NONE
