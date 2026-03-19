extends RefCounted

#adapted from <https://github.com/anhthii/lrc-parser/blob/master/index.js>
#{metadata: Dict of field: values,
# scripts: Array of LrcScripts}

const LrcObject = preload("../lrc/LrcObject.gd")
const LrcScript = preload("../lrc/LrcScript.gd")


func parse_lrc_from_path(path: String) -> LrcObject:
	var f = FileAccess.open(path, FileAccess.READ)
	var ret
	if f.get_open_error() == OK:
		ret = parse_lrc(f)

	return ret


func parse_lrc(f: FileAccess) -> LrcObject:
	var regex_time := RegEx.new()
	var regex_start_and_lyrics := RegEx.new()

	var time_start_exp = "\\[(\\d*:\\d*.?\\d*)\\]"
	var script_text_exp = "(.+)"

	regex_time.compile(time_start_exp)
	regex_start_and_lyrics.compile(time_start_exp + script_text_exp)

	var metadata = {}
	var scripts = []  #Array of LrcScripts

	var array_that_has_all_the_scripts = []
	var array_that_has_all_the_info = []

	while !f.eof_reached():
		var line = f.get_line()
		if line.strip_edges().is_empty():
			continue

		if regex_start_and_lyrics.search(line) || regex_time.search(line):
			array_that_has_all_the_scripts.append(line)

		else:
			array_that_has_all_the_info.append(line)

	for i in array_that_has_all_the_scripts.size():
		var start_and_lyrics = regex_start_and_lyrics.search(array_that_has_all_the_scripts[i])
		var time_end: RegExMatch

		if i < array_that_has_all_the_scripts.size() - 1:
			time_end = regex_time.search(array_that_has_all_the_scripts[i + 1])

		if start_and_lyrics:
			var t_start = _convert_time(start_and_lyrics.get_string(1))
			var text = start_and_lyrics.get_string(2)
			var t_end = -1
			if time_end:
				t_end = _convert_time(time_end.get_string())

			scripts.append(LrcScript.new(t_start, text, t_end))

	for line in array_that_has_all_the_info:
		var values = _extract_info(line)
		metadata[values[0]] = values[1]

	var result = LrcObject.new()

	result.metadata = metadata
	result.scripts = scripts

	return result


func _extract_info(data: String):
	var info = data.strip_edges().trim_prefix("[").trim_suffix("]")
	return info.split(":", true, 1)


func _convert_time(string: String) -> float:
	var values = string.split(":")
	var minutes: int = values[0] as int
	var seconds: float = values[1] as float

	return minutes * 60 + seconds
