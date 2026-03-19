class_name ObservableDict

signal added(key, value)
signal changed(key, old_value, new_value)
signal erased(key, value)

var _dict: Dictionary


func _init(initial_dict = {}):
	_dict = initial_dict


func get_value(key: String, default = null):
	return _dict.get(key, default)


func set_value(key: String, value):
	var old_value = _dict.get(key)
	_dict[key] = value

	if old_value == null:
		added.emit(key, value)
	changed.emit(key, old_value, value)


func has(key: String) -> bool:
	return _dict.has(key)


func erase(key: String) -> bool:
	if not _dict.has(key):
		return false

	var value = _dict[key]
	_dict.erase(key)
	erased.emit(key, value)
	changed.emit(key, value, null)
	return true
