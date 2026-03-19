@tool
extends EditorPlugin

var panel: Control


func _enter_tree():
	panel = preload("res://addons/record-replay/RecordReplayPanel.tscn").instantiate()
	panel.editor_interface = get_editor_interface()
	add_control_to_bottom_panel(panel, "RecordReplay")


func _exit_tree():
	remove_control_from_bottom_panel(panel)
	panel.queue_free()
	panel = null
