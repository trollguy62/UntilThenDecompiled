extends Control

@onready var focus: Focus = $"../../../Focus"


func _ready():
	focus.active_changed.connect(_on_focus_active_changed)
	_on_focus_active_changed(focus.active)


func _on_focus_active_changed(active: bool):
	visible = not active
