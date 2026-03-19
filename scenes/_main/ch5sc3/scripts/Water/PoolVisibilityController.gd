extends Node

var visible = false:
	set(v):
		if v:
			get_parent().visible = v
		else:
			await get_tree().process_frame
			get_parent().visible = v
		visible = v
