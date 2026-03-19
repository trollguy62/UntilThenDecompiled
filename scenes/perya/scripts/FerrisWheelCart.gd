@tool
extends MeshInstance3D


func _process(delta):
	rotation_degrees = Vector3(-get_parent().rotation_degrees.z, -90, 0)
