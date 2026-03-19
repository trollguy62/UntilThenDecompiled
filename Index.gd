extends Node

var _class_indices = {
	"SkitContainer": UniqueClassIndex.new("id"),
	"SpeechBubblePivot": MultipleClassIndex.new("alias"),
	"StateContainer": UniqueClassIndex.new("alias"),
	"PlayerTargetPosition": UniqueClassIndex.new("alias"),
}


func _enter_tree():
	var tree = get_tree()
	tree.node_added.connect(_on_node_added)
	tree.node_removed.connect(_on_node_removed)


func get_with(
	cls: String, key_value: String, predicate: Callable = Callable(), predicate_args: Array = []
) -> Node:
	if not cls in _class_indices:
		return null

	var index: ClassIndex = _class_indices[cls]
	var node_arr: Array = index.get_with(key_value)

	if not predicate.is_null():
		for node in node_arr:
			var args = [node] + predicate_args
			# Explicit true check intended here
			if predicate.callv(args) == true:
				return node
	elif not node_arr.is_empty():
		return node_arr[0]

	return null


func _on_node_added(node: Node):
	var cls = Utils.get_custom_class_of(node)
	if cls in _class_indices:
		_class_indices[cls].add(node)


func _on_node_removed(node: Node):
	var cls = Utils.get_custom_class_of(node)
	if cls in _class_indices:
		_class_indices[cls].remove(node)


# Nested classes below are for internal use only!
class ClassIndex:
	var _key: String
	var _nodes := {}

	func _init(key: String):
		_key = key

	func add(node: Node):
		assert(false)

	func remove(node: Node):
		assert(false)

	func get_with(key_value: String) -> Array:
		assert(false)
		return []

	func _is_match(node: Node, key_value: String) -> bool:
		return node[_key] == key_value


class UniqueClassIndex:
	extends ClassIndex

	func _init(key: String):
		super(key)

	func add(node: Node):
		_nodes[node[_key]] = node

	func remove(node: Node):
		var key_value = node[_key]
		if key_value in _nodes:
			_nodes.erase(key_value)

	func get_with(key_value: String) -> Array:
		if not key_value in _nodes:
			return []

		var node = _nodes[key_value]

		if is_instance_valid(node) and _is_match(node, key_value):
			return [node]
		else:
			_nodes.erase(key_value)
			return []


class MultipleClassIndex:
	extends ClassIndex

	func _init(key: String):
		super(key)

	func add(node: Node):
		var key_value = node[_key]
		if not key_value in _nodes:
			_nodes[key_value] = []

		var node_arr = _nodes[key_value]
		if not node in node_arr:
			node_arr.append(node)

	func remove(node: Node):
		var key_value = node[_key]
		if key_value in _nodes:
			_nodes[key_value].erase(node)

	func get_with(key_value: String) -> Array:
		if not key_value in _nodes:
			return []

		var node_arr = _nodes[key_value]

		for node in node_arr:
			if not is_instance_valid(node) or not _is_match(node, key_value):
				node_arr.erase(node)

		if node_arr.is_empty():
			_nodes.erase(key_value)
			return []

		return node_arr.duplicate()
