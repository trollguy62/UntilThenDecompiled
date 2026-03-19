@tool
extends EditorPlugin

var panel: Control


func _enter_tree():
	panel = preload("res://addons/migs/MigsPanel.tscn").instantiate()
	panel.editor_interface = get_editor_interface()
	add_control_to_bottom_panel(panel, "Migs")


func _exit_tree():
	remove_control_from_bottom_panel(panel)
	panel.queue_free()
	panel = null
