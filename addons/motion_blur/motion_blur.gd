@tool
extends MeshInstance3D

@export_range(2, 50) var iteration_count = 30
@export_range(0.0, 1.0) var intensity = 1.0
@export var make_visible = true

@export var override_linear_velocity = false
@export var linear_velocity = Vector3.ZERO

var cam_pos_prev = Vector3()
var cam_rot_prev = Quaternion()


func _ready():
	if not Engine.is_editor_hint() and make_visible:
		visible = true


func _process(_delta):
	var mat: ShaderMaterial = get_surface_override_material(0)
	var cam = get_parent()
	assert(cam is Camera3D)

	# Linear velocity is just difference in positions between two frames.
	var velocity = cam.global_transform.origin - cam_pos_prev
	if override_linear_velocity:
		velocity = linear_velocity

	# Angular velocity is a little more complicated, as you can see.
	# See https://math.stackexchange.com/questions/160908/how-to-get-angular-velocity-from-difference-orientation-quaternion-and-time
	var cam_rot = Quaternion(cam.global_transform.basis)
	var cam_rot_diff = cam_rot - cam_rot_prev
	var cam_rot_conj = conjugate(cam_rot)
	var ang_vel = (cam_rot_diff * 2.0) * cam_rot_conj;
	ang_vel = Vector3(ang_vel.x, ang_vel.y, ang_vel.z) # Convert Quat to Vector3

	mat.set_shader_parameter("linear_velocity", velocity)
	mat.set_shader_parameter("angular_velocity", ang_vel)
	mat.set_shader_parameter("iteration_count", iteration_count)
	mat.set_shader_parameter("intensity", intensity)

	cam_pos_prev = cam.global_transform.origin
	cam_rot_prev = Quaternion(cam.global_transform.basis)


# Calculate the conjugate of a quaternion.
func conjugate(quat):
	return Quaternion(-quat.x, -quat.y, -quat.z, quat.w)
