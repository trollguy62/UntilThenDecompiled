extends Area3D

@export_enum("Default", "Soil", "Concrete", "Grass", "WoodBridge", "CreakyWood") var ground_type: String = "Default"


func _ready():
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed():
	monitorable = visible
	monitoring = visible
