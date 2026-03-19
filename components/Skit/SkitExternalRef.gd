extends Node
class_name SkitExternalRef

enum ExtraCoverage { NONE, DIRECT_CHILDREN, DESCENDANTS }

@export var reference: NodePath
@export var extra_coverage := ExtraCoverage.NONE


func get_ref() -> Node:
	var node = get_node(reference)
	assert(node != null)
	return node


func get_extra_refs() :
	if extra_coverage == ExtraCoverage.DIRECT_CHILDREN:
		return get_ref().get_children()
	elif extra_coverage == ExtraCoverage.DESCENDANTS:
		return _get_descendants(get_ref())

	return []


func _get_descendants(node: Node):
	var result = []

	for child in node.get_children():
		result.append(child)
		result.append_array(_get_descendants(child))

	return result
