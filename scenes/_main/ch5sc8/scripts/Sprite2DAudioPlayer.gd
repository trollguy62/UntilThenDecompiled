extends Node

@onready var on_drag_start_sfx = $OnDragStart
@onready var on_drag_stop_sfx = $OnDragStop
@onready var movable_sprite = get_parent()


func _ready():
	movable_sprite.drag_start.connect(_on_drag_start)
	movable_sprite.drag_stop.connect(_on_drag_stop)


func _on_drag_start():
	on_drag_start_sfx.play()
	on_drag_stop_sfx.stop()


func _on_drag_stop():
	on_drag_stop_sfx.play()
	on_drag_start_sfx.stop()
