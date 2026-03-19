@tool
extends MeshInstance3D

@export var partition_width := 0.5:
	set(value):
		partition_width = value
		if is_node_ready():
			_update()
	
@export var total_width := 0.0:
	set(value):
		total_width = value
		if is_node_ready():
			_update()

@onready var quad := mesh as QuadMesh
@onready var shader := material_override as ShaderMaterial

@onready var orb_end := $OrbEnd
@onready var orb_start := $OrbStart


func _ready():
	orb_end.visible = true
	orb_start.visible = true
	_update()


func _update():
	visible = total_width > Constants.EPSILON
	if not visible:
		return
	
	mesh.size.x = total_width
	mesh.center_offset.x = total_width / 2.0
	orb_end.position.x = total_width
	shader.set_shader_parameter("width", total_width / partition_width)
