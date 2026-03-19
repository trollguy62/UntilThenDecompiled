extends Node

@onready var viewport = get_viewport()

var override_camera: Camera3D:
	set(value):
		override_camera = value
		_update_viewport_camera()

var current_camera: Camera3D


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Using _process causes flickers when current camera changes twice in a row

	RenderingServer.frame_pre_draw.connect(_on_frame_pre_draw)


func _on_frame_pre_draw():
	var viewport_camera = viewport.get_camera_3d()
	if viewport_camera != override_camera:
		current_camera = viewport_camera
		_update_viewport_camera()


func _update_viewport_camera():
	if is_instance_valid(override_camera):
		override_camera.current = true
	elif is_instance_valid(current_camera):
		current_camera.current = true
