@tool
extends Node3D

@onready var beam: MeshInstance3D = $Beam
@onready var end: MeshInstance3D = $End


func _process(delta):
	if beam:
		var b = beam.get_length()
		if beam.get_length() > 0.01:
			end.transform.origin = Vector3(beam.get_length(), 0.0, 0.0)
			end.show()
		else:
			end.hide()
