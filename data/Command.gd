class_name Command
const WORD_FIRST_CHAR = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-!%$"
const FLAG_PREFIX = "--"

const Substory = preload("res://data/story/Substory.gd")

enum { TOK_NONE, TOK_STR, TOK_WORD, TOK_NUM }

var raw: String
var name: String
var params: Array = []
var flags: Array[String] = []

var tags: Dictionary:
	get: return tags

var _substory_ref: WeakRef
var substory: Substory:
	get: return _substory_ref.get_ref()


func _init(raw: String, tags: Dictionary = {}, substory = null):
	self.raw = raw
	self.tags = tags
	_substory_ref = weakref(substory)

	var result := Constants.REGEX_COMMAND.search(raw)

	self.name = result.strings[1]
	if result.strings.size() >= 3:
		_parse_args(result.strings[2])


func _parse_args(raw_args: String):
	var tok = TOK_NONE
	var tmp = ""
	var str_esc = false

	for i in range(raw_args.length() + 1):
		var c = " "
		var push
		if i < raw_args.length():
			c = raw_args[i]

		if tok == TOK_NONE:
			if c in "0123456789.":
				tmp += c
				tok = TOK_NUM
			elif c == '"':
				tok = TOK_STR
			elif c in WORD_FIRST_CHAR:
				tok = TOK_WORD
				tmp += c
		elif tok == TOK_NUM:
			if c == " ":
				push = float(tmp) if "." in tmp else int(tmp)
			elif c == ".":
				if "." in tmp:
					tok = TOK_WORD
				tmp += c
			elif c in "0123456789":
				tmp += c
		elif tok == TOK_STR:
			if c == '"' and not str_esc:
				push = tmp
			elif c == "\\" and not str_esc:
				str_esc = true
			else:
				tmp += c
				str_esc = false
		elif tok == TOK_WORD:
			if c == " ":
				push = tmp
			else:
				tmp += c

		if push != null:
			var push_as_flag = false

			if push is String and tok == TOK_WORD:
				if push.begins_with(FLAG_PREFIX):
					push = push.trim_prefix(FLAG_PREFIX)
					push_as_flag = true
				else:
					var push_l = push.to_lower()
					if push_l == "true":
						push = true
					elif push_l == "false":
						push = false

			if push_as_flag:
				flags.append(push)
			else:
				params.append(push)

			tok = TOK_NONE
			tmp = ""

	assert(tok == TOK_NONE, "Arg parser didn't close (raw: %s)" % raw)
