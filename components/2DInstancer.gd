@tool
extends Node3D

enum Placement {
	XY, XZ
}

@export var object: PackedScene
@export_range (0, 99) var x_count: int = 1
@export_range ( 0, 99) var y_count: int = 1
@export var placement: Placement = Placement.XY
@export var offset: Vector3 = Vector3.ZERO
@export var size_mult: Vector3 = Vector3.ONE
@export var scale_mult: Vector3 = Vector3.ONE
@export var random_individual_offset: Vector3 = Vector3.ZERO
@export var exclude: Array[Vector2] = []
@export var editor_update = false
@export var reset_ingame = false


func _ready():
	if reset_ingame:
		_clear_and_place()


func _process(delta):
	if Engine.is_editor_hint() and editor_update:
		_clear_and_place()


func _is_excluded(i, j):
	for e in exclude:
		if e.x == i and e.y == j:
			return true
	return false


func _clear_and_place():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	if object == null:
		return

	for i in range(x_count):
		for j in range(y_count):
			if _is_excluded(i, j):
				continue

			var inst = object.instantiate()
			var size = Vector3.ZERO

			if inst is Sprite3D:
				var size_2d = inst.texture.get_size() * inst.pixel_size
				size = Vector3(size_2d.x, size_2d.y, 0)

			size *= size_mult * scale_mult
			inst.scale *= scale_mult

			var idx: Vector3
			match placement:
				Placement.XY:
					idx = Vector3(i, j, i + j)
				Placement.XZ:
					idx = Vector3(i, i + j, j)

			inst.transform.origin.x = (size.x + offset.x) * idx.x
			inst.transform.origin.y = (size.y + offset.y) * idx.y
			inst.transform.origin.z = (size.z + offset.z) * idx.z

			inst.transform.origin += Vector3(
				randf_range(-random_individual_offset.x, random_individual_offset.x),
				randf_range(-random_individual_offset.y, random_individual_offset.y),
				randf_range(-random_individual_offset.z, random_individual_offset.z),
			)

			add_child(inst)

			if Engine.is_editor_hint:
				inst.set_owner(get_tree().get_edited_scene_root())
