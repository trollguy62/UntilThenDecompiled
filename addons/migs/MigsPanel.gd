@tool
extends PanelContainer

@onready var _op_item_list := $HBoxContainer/VBoxOperations/ItemList

@onready var _match_item_list := $HBoxContainer/VBoxMatches/ItemList
@onready var _match_btn_exclude := $HBoxContainer/VBoxMatches/HBoxContainer/BtnExclude
@onready var _match_btn_apply := $HBoxContainer/VBoxMatches/HBoxContainer/BtnApply
@onready var _match_btn_apply_all := $HBoxContainer/VBoxMatches/HBoxContainer/BtnApplyAll

@onready var _extscene_item_list := $HBoxContainer/VBoxExtScenes/ItemList

var editor_interface: EditorInterface

var _operations: Array[Operation] = [
	Operation.new(
		"Convert CustomDecal to Decal",
		func(n: Node):
			return n is CustomDecal,
		func(from: CustomDecal) -> Decal:
			var to := Decal.new()
			var box_size := Vector3.ONE

			if from.mesh is BoxMesh:
				box_size = from.mesh.size

			to.size = box_size * from.scale
			var tmp = to.size.z
			to.size.z = to.size.y
			to.size.y = tmp

			to.texture_albedo = from.albedo
			to.texture_emission = from.emission
			to.texture_normal = from.normal_map
			to.modulate = from.albedo_tint
			to.emission_energy = from.emission_strength

			to.name = from.name
			to.set_meta("t", from.transform)

			return to,
		func(to: Decal):
			to.transform = to.get_meta("t")
			to.remove_meta("t")
			to.scale = Vector3.ONE
			to.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))
			),

	Operation.new(
		"Correct plane ArrayMesh normals",
		func(n: Node):
			return n is MeshInstance3D \
				and n.mesh is ArrayMesh \
				and n.mesh.resource_path.contains("::") \
				and n.mesh.get_surface_count() == 1 \
				and n.mesh.get_aabb().size.z <= 0.0001 \
				and not n.mesh.has_meta("_"),
		func(mi: MeshInstance3D):
			var mesh = mi.mesh as ArrayMesh
			var aabb = mesh.get_aabb()

			var quad = QuadMesh.new()
			quad.size = Vector2(aabb.size.x, aabb.size.y)
			quad.center_offset = Vector3(
				aabb.position.x + (aabb.size.x / 2.0),
				aabb.position.y + (aabb.size.y / 2.0),
				0.0
			)

			var st = SurfaceTool.new()
			st.create_from(quad, 0)
			mi.mesh = st.commit()
			mi.mesh.surface_set_material(0, mesh.surface_get_material(0))
			mi.mesh.set_meta("_", 1)
			),

	Operation.new(
		"Remove Camera3D environment",
		func(n: Node): return n is Camera3D and n.environment != null,
		func(n: Camera3D): n.environment = null
	),

	Operation.new(
		"Convert AudioBankLoader to StudioBankLoader",
		func(n: Node): return n is AudioBankLoader,
		func(n: AudioBankLoader): return n.as_studio_bank_loader()
	),

	Operation.new(
		"Convert AudioEventEmitter to StudioEventEmitter2/3D",
		func(n: Node): return n is AudioEventEmitter,
		func(n: AudioEventEmitter): return n.as_studio_event_emitter()
	)
]

var _current_matches: Array[NodePath]
var _current_ext_scenes: Dictionary
var _current_op: Operation
var _last_scene_root: Node

func _ready():
	_populate_operations()
	_clear_result()

	_op_item_list.item_selected.connect(_on_operation_selected)

	_match_item_list.item_activated.connect(_on_match_activated)
	_match_btn_exclude.pressed.connect(_on_match_btn_exclude_pressed)
	_match_btn_apply.pressed.connect(_on_match_btn_apply_pressed)
	_match_btn_apply_all.pressed.connect(_on_match_btn_apply_all_pressed)

	_extscene_item_list.item_activated.connect(_on_extscene_activated)


func _process(delta):
	var scene_root := get_tree().edited_scene_root

	if _last_scene_root != scene_root:
		_last_scene_root = scene_root

		if scene_root != null:
			if _current_op != null:
				var op_idx := _operations.find(_current_op)
				_on_operation_selected(op_idx)
			else:
				_clear_all()


func _search(node: Node, predicate: Callable, nodes: Array[NodePath], ext_scenes: Dictionary):
	if node != null and node.scene_file_path != "" and not node.scene_file_path in ext_scenes:
		ext_scenes[node.scene_file_path] = 0
		var ext_nodes: Array[NodePath] = []
		_search(node, predicate, ext_nodes, ext_scenes)
		ext_scenes[node.scene_file_path] = ext_nodes.size()
	else:
		if node == null:
			node = get_tree().edited_scene_root
		if predicate.call(node):
			nodes.append(get_tree().edited_scene_root.get_path_to(node))
		for child in node.get_children():
			_search(child, predicate, nodes, ext_scenes)


func _populate_operations():
	_op_item_list.clear()

	for op in _operations:
		_op_item_list.add_item(op.name)


func _clear_result():
	_match_item_list.clear()
	_extscene_item_list.clear()


func _clear_all():
	_clear_result()
	_op_item_list.deselect_all()

	_current_op = null
	_current_matches = []
	_current_ext_scenes = {}


func _populate_result(nodes: Array[NodePath], ext_scenes: Dictionary):
	_clear_result()

	for node_path in nodes:
		_match_item_list.add_item(node_path)

	for ext_scene in ext_scenes:
		var count: int = ext_scenes[ext_scene]
		if count > 0:
			_extscene_item_list.add_item("%d: %s" % [count, ext_scene])


func _on_operation_selected(idx: int):
	_current_op = Utils.array_get(_operations, idx)
	_current_matches = []
	_current_ext_scenes = {}

	if _current_op != null:
		_search(null, _current_op.predicate, _current_matches, _current_ext_scenes)
		_populate_result(_current_matches, _current_ext_scenes)


func _on_match_activated(idx: int):
	var node_path: String = _match_item_list.get_item_text(idx)
	var node: Node = get_tree().edited_scene_root.get_node(node_path)

	editor_interface.get_selection().clear()
	editor_interface.get_selection().add_node(node)


func _on_match_btn_exclude_pressed():
	_remove_selected_match(false)


func _on_match_btn_apply_pressed():
	_remove_selected_match(true)


func _on_match_btn_apply_all_pressed():
	while _match_item_list.item_count > 0:
		_match_item_list.select(0)
		_remove_selected_match(true)


func _remove_selected_match(apply: bool):
	var selected_items: PackedInt32Array = _match_item_list.get_selected_items()
	if selected_items.is_empty():
		return

	var selected_idx: int = selected_items[0]

	if apply:
		var node_path: String = _match_item_list.get_item_text(selected_idx)
		var node: Node = get_tree().edited_scene_root.get_node(node_path)
		var ret = _current_op.action.call(node)

		if ret != null and ret is Node:
			node.replace_by(ret)

			if _current_op.post_action.is_valid():
				_current_op.post_action.call(ret)

	_current_matches.remove_at(selected_idx)
	_populate_result(_current_matches, _current_ext_scenes)

	if _match_item_list.item_count > 0:
		_match_item_list.select(min(selected_idx, _match_item_list.item_count - 1))


func _on_extscene_activated(idx: int):
	var scene_path: String = _extscene_item_list.get_item_text(idx)
	scene_path = scene_path.substr(scene_path.find(":") + 2)
	editor_interface.open_scene_from_path(scene_path)


class Operation extends Resource:
	var name: String
	var predicate: Callable
	var action: Callable # May return a Node to replace the matching node
	var post_action: Callable # Called after replacing the matching node

	func _init(name: String, predicate: Callable, action: Callable, post_action: Callable = Callable()):
		self.name = name
		self.predicate = predicate
		self.action = action
		self.post_action = post_action
