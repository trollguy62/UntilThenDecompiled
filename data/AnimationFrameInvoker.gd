extends Resource
class_name AnimationFrameInvoker

@export var animation := ""
@export var frame := 0
@export var node_path: NodePath
@export var method := ""
@export var args := []
@export var deferred := false


func invoke(root: Node):
	var node = root.get_node(node_path)
	if node == null:
		return

	if deferred:
		await root.get_tree().process_frame

	node.callv(method, args)
