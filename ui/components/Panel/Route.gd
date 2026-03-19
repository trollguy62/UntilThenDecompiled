var _screen_creator: Callable  # (params: Array<String>, payload: Dictionary) -> Screen | Screen[] | null
var _regex = RegEx.new()


func _init(pattern: String, screen_creator: Callable):
	_screen_creator = screen_creator
	var regexp = ""

	for i in range(pattern.length()):
		var c = pattern[i]
		var last_char = i == pattern.length() - 1

		if c == "*":
			regexp += "([a-zA-Z_0-9.]+)"
		elif c == "/":
			regexp += "\\/"
		elif c == ">" and last_char:
			regexp += "(.*)"
		else:
			regexp += c

	_regex.compile(regexp)


func get_screen(path: String, payload: Dictionary):
	var res = _regex.search(path)
	if res == null:
		return null

	var params = res.strings
	var screen = _screen_creator.call(params, payload)
	return screen
