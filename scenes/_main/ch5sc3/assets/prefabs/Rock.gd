extends RigidBody3D

@onready var collision_mesh = $CollisionMesh

func _physics_process(delta):
	collision_mesh.material_override.set_shader_parameter("speed", abs(linear_velocity.y))
