extends Node2D

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		await get_tree().create_timer(1).timeout

	$Pointer.visible = visible
