extends MeshInstance3D

@export var material_options: Array[ShaderMaterial]


func _ready():
	assert(material_options.size() > 0)
	material_override = material_options[randi() % material_options.size()]
