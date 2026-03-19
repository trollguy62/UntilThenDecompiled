const Command = preload("res://data/Command.gd")

var _handlers = []  # Array<Callable<Command, any>>
var fallback_handler: Callable  # Last handler to call
var _last_result


func register_handler(handler: Callable):
	_handlers.append(handler)


func unregister_handler(handler: Callable):
	_handlers.erase(handler)


func run(cmd: Command):
	var invalid_handlers := []
	var result = Constants.CMD_RETURN_NONE

	for handler in _handlers:
		if not handler.is_valid():
			invalid_handlers.append(handler)
		else:
			var cmd_result = await handler.call(cmd)
			if _is_result(cmd_result):
				result = cmd_result
				break

	if not _is_result(result) and fallback_handler != null and fallback_handler.is_valid():
		var cmd_result = await fallback_handler.call(cmd)
		if _is_result(cmd_result):
			result = cmd_result

	for handler in invalid_handlers:
		_handlers.erase(handler)

	_last_result = result
	return result


func get_last_result():
	return _last_result


func _is_result(value) -> bool:
	return not value is Object or value != Constants.CMD_RETURN_NONE
