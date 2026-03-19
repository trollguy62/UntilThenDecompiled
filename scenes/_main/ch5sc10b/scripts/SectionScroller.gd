extends Node3D

const MAGIC = 10000
const META_KEY_START_OFFSET = "_offset0"
const META_KEY_END_OFFSET = "_offset1"
const META_KEY_UID = "_uid"

# Can change in runtime
@export var enabled = false
@export var appending = true:
	set	= _set_appending
@export var speed = 0.0

# Shouldn't change in runtime
@export var reverse = false
@export_range(2, 8) var section_count = 2
@export var default_sections: Array[PackedScene]
@export var special_sections: Array[PackedScene]

@export var debug_append_special_section = -1:
	set = _set_debug_append_special_section

var _track = []  # Node[]
var _section_cache = {}  # Map<int, Node[]>
var _special_section_queue = []  # int[]
var _next_default_idx = 0
var _spawned = {}  # Map<String, bool>

var _skit_container: SkitContainer


func _ready():
	# Remove all children
	for child in get_children():
		if child.name.begins_with("+"):
			if child.name.begins_with("+Spawn"):
				_spawned[child.name] = false
				child.visible = false
		else:
			child.queue_free()

	# Cache one instance per section
	for i in range(default_sections.size()):
		_get_unused_section(_section_uid(i, false))
	for i in range(special_sections.size()):
		_get_unused_section(_section_uid(i, true))

	self.appending = appending


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container


func _set_appending(value: bool):
	appending = value

	if is_inside_tree() and appending:
		var count = max(0, section_count - _track.size())
		for i in range(count):
			_append_section(_get_unused_section(_next_uid()))


func _notification(what):
	if what != NOTIFICATION_PREDELETE:
		return

	for cached_instances in _section_cache.values():
		for inst in cached_instances:
			if is_instance_valid(inst) and not inst.is_queued_for_deletion():
				inst.queue_free()


func _process(delta):
	var skit_active = (
		Engine.is_editor_hint()
		or (is_instance_valid(_skit_container) and _skit_container.is_running)
	)

	if not enabled or not skit_active:
		return

	# Scroll
	var dx = abs(speed) * delta
	if reverse:
		dx *= -1

	for e in _track:
		e.translate(Vector3.LEFT * dx)

	for child_name in _spawned.keys():
		var spawnable = get_node(child_name)

		if _spawned[child_name] == false:
			spawnable.visible = false
			continue

		spawnable.visible = true
		spawnable.translate(Vector3.LEFT * dx)

		var x_pos = spawnable.transform.origin.x
		var despawn = (x_pos > 5) if reverse else (x_pos < -5)

		if despawn:
			_spawned[child_name] = false  # despawn in next frame

	# Determine removable sections
	var removable_sections = {}  # Map<int, Node[]>
	var remove_count = 0

	for section in _track:
		var removable = false
		if reverse:
			removable = section.transform.origin.x + _get_section_start_offset(section) > 0
		else:
			removable = section.transform.origin.x + _get_section_end_offset(section) < 0

		if removable:
			var uid = _get_section_uid(section)

			if not removable_sections.has(uid):
				removable_sections[uid] = []

			removable_sections[uid].append(section)
			remove_count += 1
		else:
			break

	# Append sections
	for i in range(remove_count):
		_track.pop_front()

		if not appending:
			continue

		var next_uid = _next_uid()
		var next_section: Node

		# Reuse removable section if needed, as an optimization
		# This avoids having to remove and add the section from and back into the scene tree
		if removable_sections.has(next_uid):
			var r = removable_sections[next_uid]
			next_section = r.pop_front()

		# Get from cache/make new instance otherwise
		if next_section == null:
			next_section = _get_unused_section(next_uid)

		_append_section(next_section)

	# Remove remaining removable sections
	for r in removable_sections.values():
		for section in r:
			remove_child(section)


func enqueue_special_section(idx: int):
	if idx >= 0 and idx < special_sections.size():
		_special_section_queue.append(idx)


func spawn(key: String):
	var child_name = "+Spawn" + key
	if _spawned.has(child_name):
		_spawned[child_name] = true
		get_node(child_name).transform.origin = Vector3.RIGHT * _get_last_x_pos()


func _next_uid() -> int:
	if _special_section_queue.size() > 0:
		var idx = _special_section_queue.pop_front()
		return _section_uid(idx, true)
	else:
		var idx = _next_default_idx
		_next_default_idx = (_next_default_idx + 1) % default_sections.size()
		return _section_uid(idx, false)


func _append_section(node: Node):
	assert(not _track.has(node))
	assert(_track.size() < section_count)

	var offset = _get_section_end_offset(node) if reverse else _get_section_start_offset(node)
	var x_pos = _get_last_x_pos() - offset
	node.transform.origin = Vector3.RIGHT * x_pos

	_track.append(node)

	if node.get_parent() != self:
		add_child(node)


func _get_last_x_pos() -> float:
	if _track.is_empty():
		return 0.0

	var last_section = _track[-1]
	var offset = (
		_get_section_start_offset(last_section)
		if reverse
		else _get_section_end_offset(last_section)
	)
	return last_section.transform.origin.x + offset


# Caches instances or creates new ones if needed
func _get_unused_section(uid: int) -> Node:
	var cached_instances: Array

	if _section_cache.has(uid):
		cached_instances = _section_cache[uid]
	else:
		cached_instances = []
		_section_cache[uid] = cached_instances

	for inst in cached_instances:
		if not inst.is_inside_tree():
			return inst

	var section_scene = _get_section_scene_from_uid(uid)
	var new_inst = section_scene.instantiate()

	var start_offset = 999.0
	var end_offset = -999.0

	for child in new_inst.get_children():
		if child.name.begins_with("+Bound"):
			var child_x = child.transform.origin.x

			start_offset = min(child_x, start_offset)
			end_offset = max(child_x, end_offset)

			child.queue_free()

	new_inst.set_meta(META_KEY_START_OFFSET, start_offset)
	new_inst.set_meta(META_KEY_END_OFFSET, end_offset)
	new_inst.set_meta(META_KEY_UID, uid)

	cached_instances.append(new_inst)
	return new_inst


func _get_section_start_offset(node: Node) -> float:
	return node.get_meta(META_KEY_START_OFFSET, 0)


func _get_section_end_offset(node: Node) -> float:
	return node.get_meta(META_KEY_END_OFFSET, 0)


func _get_section_uid(node: Node) -> int:
	return node.get_meta(META_KEY_UID, 0)


func _get_section_scene_from_uid(uid: int) -> PackedScene:
	if uid < 0:
		return special_sections[uid + MAGIC]
	else:
		return default_sections[uid]


func _section_uid(idx: int, special: bool) -> int:
	return idx - (MAGIC if special else 0)


func _set_debug_append_special_section(idx: int):
	enqueue_special_section(idx)
