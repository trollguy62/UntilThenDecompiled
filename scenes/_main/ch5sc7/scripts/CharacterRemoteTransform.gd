extends RemoteTransform3D

var _skit_container: SkitContainer


func _skit_start(skit_container: SkitContainer):
	_skit_container = skit_container
	enable_transform(true)


func enable_transform(enable):
	update_position = enable
	update_rotation = enable
	update_scale = enable
