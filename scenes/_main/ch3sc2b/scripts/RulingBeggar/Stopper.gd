extends Node

@onready var sprite = get_node("../../Sprite")
@onready var path_grounder = get_parent()

@onready var stop_1 = get_node("../../../Stop1")
@onready var stop_2 = get_node("../../../Stop2")

var _walk_count = 0


func _ready():
	Story.emitted.connect(_on_story_emit)


func _on_story_emit(emit_name: String, value):
	match emit_name:
		"beggar_walk":
			_walk_count += 1
			
			if _walk_count == 3:
				stop_1.queue_free()
				stop_2.queue_free()
				await get_tree().process_frame
			
			path_grounder.enabled = true
		
		"beggar_stop":
			if _walk_count < 3:
				path_grounder.enabled = false
				sprite.animation = "still"
