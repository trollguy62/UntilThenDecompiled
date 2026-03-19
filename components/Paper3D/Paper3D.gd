@tool
extends MeshInstance3D
class_name Paper3D

const SmoothSpatialOpaque = preload("res://assets/shaders/SmoothSpatialOpaque.tres")
const SmoothSpatialTransparent = preload("res://assets/shaders/SmoothSpatialTransparent.tres")

const META_MAT_OPAQUE = &"mat_opaque"
const META_MAT_TRANSPARENT = &"mat_transparent"

@export var texture: Texture:
	set(value):
		texture = value
		_update_mesh()

@export_range(0.0001, 16) var pixel_size: float = 0.01:
	set(value):
		pixel_size = value
		_update_mesh()

@export var centered := false:
	set(value):
		centered = value
		_update_mesh()

@export var offset := Vector3():
	set(value):
		offset = value
		_update_mesh()

@export var flip_h := false:
	set(value):
		flip_h = value
		_update_mesh()

@export var flip_v := false:
	set(value):
		flip_v = value
		_update_mesh()

@export var modulate := Color.WHITE:
	set(value):
		modulate = value
		_update_material()

@export var transparent := false:
	set(value):
		transparent = value
		_update_material()

@export var transparent_two_pass := false:
	set(value):
		transparent_two_pass = value
		_update_material()

@export var emission := Color.BLACK:
	set(value):
		emission = value
		_update_material()

@export var emission_texture: Texture:
	set(value):
		emission_texture = value
		_update_material()

@export_range(0, 16) var emission_energy: float = 1.0:
	set(value):
		emission_energy = value
		_update_material()

@export_range(0, 8) var emission_saturation: float = 1.0:
	set(value):
		emission_saturation = value
		_update_material()

@export var emission_blend_add := true:
	set(value):
		emission_blend_add = value
		_update_material()

@export var y_billboard := false:
	set(value):
		y_billboard = value
		_update_material()

var _ready := false

# We use meta here to serialize the materials for reuse
var _mat_opaque: Material:
	set(value):
		set_meta(META_MAT_OPAQUE, value)
	get:
		if not has_meta(META_MAT_OPAQUE):
			return null
		else:
			return get_meta(META_MAT_OPAQUE) as Material

var _mat_transparent: Material:
	set(value):
		set_meta(META_MAT_TRANSPARENT, value)
	get:
		if not has_meta(META_MAT_TRANSPARENT):
			return null
		else:
			return get_meta(META_MAT_TRANSPARENT) as Material


func _enter_tree():
	_ready = true
	# TODO: This happens in runtime. This used to be cached in editor. See Git history.
	# However, cached meshes don't work for editable children.
	# So before you reimplement the usage of cached mesh, make sure they also work for editable children.
	_update_mesh()


func _update_mesh():
	if not (_ready or Engine.is_editor_hint()):
		return

	if texture == null:
		mesh = null
		return

	var tex_size = texture.get_size()
	var vert_size = tex_size * pixel_size
	var vert_px_offset = (
		offset
		- (Vector3(tex_size.x / 2.0, tex_size.y / 2.0, 0) if centered else Vector3.ZERO)
	)
	var vert_offset = vert_px_offset * pixel_size

	var array_mesh = mesh

	if array_mesh is ArrayMesh:
		array_mesh.clear_surfaces()
	else:
		array_mesh = ArrayMesh.new()

	var verts = PackedVector3Array(
		[
			Vector3(0, 0, 0) + vert_offset,
			Vector3(vert_size.x, 0, 0) + vert_offset,
			Vector3(vert_size.x, vert_size.y, 0) + vert_offset,
			Vector3(0, vert_size.y, 0) + vert_offset
		]
	)

	var uvs_arr = [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)]
	if flip_h:
		_swap_arr(uvs_arr, 0, 1)
		_swap_arr(uvs_arr, 2, 3)
	if flip_v:
		_swap_arr(uvs_arr, 0, 3)
		_swap_arr(uvs_arr, 1, 2)
	var uvs = PackedVector2Array(uvs_arr)

	var normals = PackedVector3Array(
		[Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1)]
	)

	var tangents = PackedFloat32Array([1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1])

	var indices = PackedInt32Array([0, 3, 2, 0, 2, 1])

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TANGENT] = tangents
	arrays[Mesh.ARRAY_INDEX] = indices

	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh = array_mesh

	_update_material()


func _update_material():
	if (_ready or Engine.is_editor_hint()) and mesh != null:
		var make_mat_opaque = transparent_two_pass or not transparent
		var make_mat_transparent = transparent

		var mat: Material

		if make_mat_transparent:
			if _mat_transparent == null:
				_mat_transparent = SmoothSpatialTransparent.duplicate()

			mat = _mat_transparent
			_set_material_props(mat)

		if make_mat_opaque:
			if _mat_opaque == null:
				_mat_opaque = SmoothSpatialOpaque.duplicate()

			_set_material_props(_mat_opaque)

			if mat != null:
				mat.next_pass = _mat_opaque
			else:
				mat = _mat_opaque

		if not transparent:
			_mat_transparent = null

		mesh.surface_set_material(0, mat)


func _set_material_props(mat: Material):
	mat.set_shader_parameter("albedo", modulate)
	mat.set_shader_parameter("texture_albedo", texture)

	mat.set_shader_parameter("emission", emission)
	mat.set_shader_parameter("texture_emission", emission_texture)
	mat.set_shader_parameter("emission_energy", emission_energy)
	mat.set_shader_parameter("emission_saturation", emission_saturation)
	mat.set_shader_parameter("emission_blend_add", emission_blend_add)
	mat.set_shader_parameter("y_billboard", y_billboard)


func _swap_arr(arr: Array, i: int, j: int):
	var tmp = arr[i]
	arr[i] = arr[j]
	arr[j] = tmp
