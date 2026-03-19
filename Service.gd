extends Node

const NAVIGATOR = "ScreenNavigator"
const NOTIFIER = "NotificationHandler"

var _instance_ids := BiDictionary.new()  # BiDictionary<String, int>


func _enter_tree():
	var tree = get_tree()
	tree.node_added.connect(_on_node_added)
	tree.node_removed.connect(_on_node_removed)
	tree.node_renamed.connect(_on_node_renamed)


func of(service_name: String):
	if _instance_ids.has_first(service_name):
		var id = _instance_ids.get_by_first(service_name)
		var node = instance_from_id(id)
		if node is Node:
			return node

	return null


func _on_node_added(node: Node):
	var service_name = _get_service_name(node)
	if service_name != "":
		_instance_ids.set_entry(service_name, node.get_instance_id())


func _on_node_removed(node: Node):
	var service_name = _get_service_name(node)
	if _instance_ids.has_first(service_name):
		_instance_ids.remove_by_first(service_name)


func _on_node_renamed(node: Node):
	var id = node.get_instance_id()
	if _instance_ids.has_second(id):
		_instance_ids.remove_by_second(id)
		_on_node_added(node)


func _get_service_name(node: Node) -> String:
	var name = node.name
	if name.length() > 1 and name.begins_with("$"):
		return name.substr(1)
	return ""


class BiDictionary:
	var _x_to_y := {}
	var _y_to_x := {}

	func set_entry(x, y):
		_x_to_y[x] = y
		_y_to_x[y] = x

	func has_first(x) -> bool:
		return x in _x_to_y

	func has_second(y) -> bool:
		return y in _y_to_x

	func remove_by_first(x) -> bool:
		if has_first(x):
			var y = _x_to_y[x]
			_y_to_x.erase(y)
			_x_to_y.erase(x)
			return true
		return false

	func remove_by_second(y) -> bool:
		if has_second(y):
			var x = _y_to_x[y]
			_x_to_y.erase(x)
			_y_to_x.erase(y)
			return true
		return false

	func get_by_first(x):
		return _x_to_y[x] if has_first(x) else null

	func get_by_second(y):
		return _y_to_x[y] if has_second(y) else null
