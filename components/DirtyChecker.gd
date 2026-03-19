extends Node
class_name DirtyChecker

signal changed

var obj
var prop: String
var _value


func _init(obj, prop: String):
	self.obj = obj
	self.prop = prop


func _ready():
	_value = _get_current_value()


func _get_current_value():
	if obj.has_method(prop):
		return obj.call(prop)

	var value = obj[prop]
	if value is Array or value is Dictionary:
		value = value.duplicate(true)
	return value


func _physics_process(_delta):
	var new_value = _get_current_value()
	if not equal(_value, new_value):
		_value = new_value
		changed.emit()


func equal(a, b) -> bool:
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not equal(a[i], b[i]):
				return false
		return true

	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for k in a:
			if not equal(a[k], b.get(k)):
				return false
		for k in b:
			if not equal(b[k], a.get(k)):
				return false
		return true

	if typeof(a) == typeof(b):
		return a == b

	return false
