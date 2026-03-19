class_name Set

var set = {}

signal changed

const OP_TYPE_ADD = 1
const OP_TYPE_REMOVE = 2
const OP_TYPE_INVERT = 3

var _in_batch_op := false
var _has_batch_op_changes := false


func has(e) -> bool:
	return e in set


func add(e):
	var added = not has(e)
	set[e] = true
	if added:
		_try_emit_changed()


func remove(e) -> bool:
	var removed = set.erase(e)
	if removed:
		_try_emit_changed()
	return removed


func invert(e):
	if has(e):
		remove(e)
	else:
		add(e)


func clear():
	if size() > 0:
		set.clear()
		_try_emit_changed()


func at(i: int):
	return to_array()[i]


func to_array() -> Array:
	return set.keys()


func apply_op(op_raw: String):
	var op = Set.get_operation(op_raw)
	match op.type:
		OP_TYPE_ADD:
			add(op.flag)
		OP_TYPE_REMOVE:
			remove(op.flag)
		OP_TYPE_INVERT:
			invert(op.flag)


func size() -> int:
	return set.size()


func is_empty() -> bool:
	return size() == 0


func start_batch_op():
	_in_batch_op = true
	_has_batch_op_changes = false


func end_batch_op():
	if _in_batch_op and _has_batch_op_changes:
		changed.emit()

	_in_batch_op = false
	_has_batch_op_changes = false


func _try_emit_changed():
	if _in_batch_op:
		_has_batch_op_changes = true
	else:
		changed.emit()


class Operation:
	var type: int
	var flag: String

	func _init(type: int, flag: String):
		self.type = type
		self.flag = flag


# "flag" - add(flag)
# "-flag" - remove(flag)
# "!flag" - invert(flag)
static func get_operation(op_raw: String) -> Operation:
	match op_raw[0]:
		"-":
			return Operation.new(OP_TYPE_REMOVE, op_raw.trim_prefix("-"))
		"!":
			return Operation.new(OP_TYPE_INVERT, op_raw.trim_prefix("!"))
	return Operation.new(OP_TYPE_ADD, op_raw)
