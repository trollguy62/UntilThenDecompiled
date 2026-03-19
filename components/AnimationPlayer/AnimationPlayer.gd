extends AnimationPlayer

const SkipHint = preload("res://components/AnimationPlayer/SkipHint.tscn")

@export var skip_start_offsets := {}

@onready var skip_hint = SkipHint.instantiate()

var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _ready():
	add_child(skip_hint)
	skip_hint.skipped.connect(_on_skipped)


func _process(delta):
	var skip_start_offset: float = skip_start_offsets.get(current_animation, -1)
	skip_hint.active = skip_start_offset >= 0 and current_animation_position >= skip_start_offset


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _on_skipped():
	seek(current_animation_length - 0.1)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	match cmd.name:
		"play":
			var anim = params[0]
			if not has_animation(anim):
				return Constants.CMD_RETURN_NONE

			var custom_speed := 1.0
			var from_end := false

			if tags.has("duration"):
				var anim_duration: float = get_animation(anim).length
				custom_speed = anim_duration / tags.get("duration")

			if flags.has("reverse"):
				custom_speed *= -1
				from_end = true

			if flags.has("clear-cache"):
				clear_caches()

			play(anim, -1, custom_speed, from_end)

			if not flags.has("no-wait"):
				await animation_finished
		"stop":
			var anim = params[0]
			if current_animation != anim:
				return Constants.CMD_RETURN_NONE

			var reset = flags.has("reset")
			stop(reset)
		_:
			return Constants.CMD_RETURN_NONE

	return null
