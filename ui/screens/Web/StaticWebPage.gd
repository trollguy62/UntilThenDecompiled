extends "WebPage.gd"

const LEAVES_PER_STAGE: float = 6.9

var params := {}


func _get_leaf_nodes(node: Node, leaves: Array = []) -> Array:
	if node is Control:
		var children = []

		for child in node.get_children():
			if child is Control:
				children.append(node)

		if children.size() > 0:
			for child in node.get_children():
				leaves = _get_leaf_nodes(child, leaves)
		elif node.visible:
			leaves.append(node)

	return leaves


func load(speed_mult: float = 1.0):
	if is_loading:
		return

	await get_tree().process_frame
	visible = false

	progress = 0
	is_loading = true

	var leaves = _get_leaf_nodes(self)
	leaves.shuffle()
	for leaf in leaves:
		leaf.visible = false

	progress = randf_range(0.2, 0.5)
	var stage_count = ceil(leaves.size() / LEAVES_PER_STAGE)
	var stage_progress = (1 - progress) / stage_count

	var d_initial = randf_range(0.8, 3)
	params = {
		"leaves": leaves,
		"speed_mult": speed_mult,
		"stage_progress": stage_progress,
		"stage_idx": 0,
		"stage_count": stage_count
	}

	timer.timeout.connect(_load)
	timer.start(d_initial / speed_mult)


func _load():
	visible = true
	var i = params.stage_idx
	var stage_count = params.stage_count
	var d_next = 1

	if i < stage_count:
		var leaves = params.leaves
		var at_last_stage = i + 1 == stage_count

		var q = leaves.size() / stage_count
		var start = i * q
		var end = start + q

		if at_last_stage:
			end = leaves.size()

		for k in range(start, end):
			leaves[k].visible = true

		if at_last_stage:
			progress = 1
			d_next = randf_range(0.2, 0.5)
		else:
			progress += params.stage_progress
			d_next = randf_range(0.6, 1.8)
	elif i == stage_count:
		cancel()
		loaded.emit()
		return

	params.stage_idx += 1
	timer.start(d_next / params.speed_mult)


func cancel():
	is_loading = false
	timer.stop()

	if timer.timeout.is_connected(_load):
		timer.timeout.disconnect(_load)
