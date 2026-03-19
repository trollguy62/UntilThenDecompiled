@tool
extends Node3D

@export var grave_scene: PackedScene
@export_range(1, 32) var amount_x := 1
@export_range(1, 32) var amount_z := 1

@export var grave_materials: Array[Material] = []
@export var gravestone_materials: Array[Material] = []

@export var gravestone_distributions: Array[float] = []

@export var debug_instance = false


func _process(_delta):
	if Engine.is_editor_hint() and debug_instance:
		_instance()


func _instance():
	assert(gravestone_materials.size() == gravestone_distributions.size())
	var gravestone_dists_normalized = _normalize_distributions(gravestone_distributions)

	print(gravestone_dists_normalized)

	for child in get_children():
		child.queue_free()

	var grave_size := Vector3.ZERO
	var gravestone_size := Vector3.ZERO

	var edited_scene_root = get_tree().edited_scene_root

	for y in range(amount_z):
		for x in range(amount_x):
			var grave = grave_scene.instance(PackedScene.GEN_EDIT_STATE_INSTANCE) as GeometryInstance3D
			var gravestone = grave.get_child(0) as GeometryInstance3D

			if grave_size.length() < 0.001:
				grave_size = grave.get_aabb().size

			if gravestone_size.length() < 0.001:
				gravestone_size = gravestone.get_aabb().size

			add_child(grave)
			grave.filename = ""
			grave.owner = edited_scene_root
			gravestone.owner = edited_scene_root

			var dy = gravestone_size.y * (0.4 + randf() * 0.5)

			var max_rot = atan(dy / gravestone_size.x)
			var rot = randf() * max_rot

			gravestone.position.x += randf_range(-0.01, 0.01)
			gravestone.position.y -= dy
			gravestone.position.z += randf_range(-0.04, 0.02)
			gravestone.rotation.x = rot

			grave.position.x = grave_size.x * x
			grave.position.z = grave_size.z * -y
			grave.scale.y = randf_range(0.9, 1.5)

			grave.material_override = _pick_random(grave_materials)
			gravestone.material_override = _pick_random(
				gravestone_materials, gravestone_dists_normalized
			)


func _normalize_distributions(dists: Array) -> Array:
	var normalized = []
	var sum = 0.0

	for d in dists:
		sum += d

	for d in dists:
		normalized.append(d / sum)

	return normalized


func _pick_random(arr: Array, normalized_dists: Array = []):
	if normalized_dists.is_empty():
		return arr[randi() % arr.size()]
	else:
		var r = randf()
		var acc = 0.0

		for i in range(normalized_dists.size()):
			acc += normalized_dists[i]
			if r <= acc:
				return arr[i]

	return arr[-1]
