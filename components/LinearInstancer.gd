@tool
extends Node3D

@export var objects: Array[PackedScene] = []
@export_range(0, 99) var count: int = 1
@export var random = false
@export var random_dist: Array[float] = []

@export var offset: Vector3 = Vector3.ZERO
@export var size_mult: Vector3 = Vector3.ONE
@export var scale_mult: Vector3 = Vector3.ONE
@export var editor_update = false
@export var reset_ingame = false

var _rand_dist_cumulative = []


func _ready():
	if reset_ingame:
		_update()


func _process(delta):
	if Engine.is_editor_hint() and editor_update:
		_update()


func _get_configuration_warning():
	if objects.is_empty():
		return "No objects"
	elif editor_update:
		return "Editor update enabled"
	else:
		return ""


func _update():
	_prepare_rand_dist()
	_clear_and_place()


func _prepare_rand_dist():
	if not random:
		return

	var dist_sum = 0
	_rand_dist_cumulative = []

	for i in range(objects.size()):
		var dist = 1
		if i < random_dist.size():
			dist = random_dist[i]

		dist_sum += dist
		_rand_dist_cumulative.append(dist_sum)

	for i in range(objects.size()):
		var n = _rand_dist_cumulative[i]
		_rand_dist_cumulative[i] = n / dist_sum


func _get_object(i: int) -> PackedScene:
	if random:
		var r = randf()
		for j in range(objects.size()):
			if r < _rand_dist_cumulative[j]:
				return objects[j]

	return objects[i % objects.size()]


func _clear_and_place():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	if objects.is_empty():
		return

	for i in range(count):
		var object = _get_object(i)
		var inst = object.instantiate()
		var size = Vector3.ZERO

		if inst is Sprite3D:
			var size_2d = inst.texture.get_size() * inst.pixel_size
			size = Vector3(size_2d.x, size_2d.y, 0)
		elif inst is MeshInstance3D:
			size = inst.get_aabb().size * inst.scale

		size *= size_mult * scale_mult
		inst.scale *= scale_mult
		inst.transform.origin = (size + offset) * i

		add_child(inst)

		if Engine.is_editor_hint():
			inst.set_owner(get_tree().get_edited_scene_root())
