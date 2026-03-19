extends Node
class_name StateContainer

const Set = preload("res://data/Set.gd")
const Command = preload("res://data/Command.gd")
signal changed

@export var alias: String = ""

@export var initial_flags: Array[String] = []
@export var initial_dict := {}

var flags := Set.new()
var dict := ObservableDict.new()


func _ready():
	flags.changed.connect(_on_flags_changed)
	dict.changed.connect(_on_dict_changed)

	for flag in initial_flags:
		flags.add(flag)

	for key in initial_dict.keys():
		dict.set_value(key, initial_dict[key])

func get_custom_class():
	return "StateContainer"


func _on_flags_changed():
	changed.emit()


func _on_dict_changed(_key, _old_value, _value):
	changed.emit()


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	if params.size() > 0 and str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"F":
			flags.start_batch_op()

			flags.clear()
			for i in range(1, params.size()):
				flags.add(params[i])

			flags.end_batch_op()
		"Fs":
			flags.start_batch_op()

			for i in range(1, params.size()):
				flags.apply_op(params[i])

			flags.end_batch_op()
		"Fc":
			flags.clear()
		"F_has":
			var flag = params[1]
			return flags.has(flag)
		"D":
			var key = params[1]
			var value = params[2]
			dict.set_value(key, value)
		"D_get":
			var key = params[1]
			return dict.get_value(key)
		"D_has":
			var key = params[1]
			return dict.has(key)
		_:
			return Constants.CMD_RETURN_NONE

	return null
