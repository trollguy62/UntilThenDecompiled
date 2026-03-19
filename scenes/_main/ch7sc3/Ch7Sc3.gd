extends Scene

const InteractiveArea = preload("res://components/InteractiveArea/InteractiveArea.gd")

@export var total_interactables: int
@export var ia_sit_path: NodePath

@onready var ia_sit = get_node(ia_sit_path) as InteractiveArea

var _items_iteracted: int


func _ready():
	super._ready()
	ia_sit.enabled = false
	Story.emitted.connect(_on_story_emit)


func _on_story_emit(emit_name: String, value):
	match emit_name:
		"item_interacted":
			_items_iteracted += 1
			_check_items_interacted()


func _check_items_interacted():
	if _items_iteracted == total_interactables:
		Story.emit("all_items_interacted")
		ia_sit.enabled = true
