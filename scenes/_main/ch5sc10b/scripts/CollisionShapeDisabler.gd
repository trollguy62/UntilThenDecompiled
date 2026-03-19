extends CollisionShape3D


func _enter_tree():
	disabled = true


func _process(_delta):
	disabled = not visible
