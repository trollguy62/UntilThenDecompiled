extends Node2D

@onready var focus = $Focus
@onready var input_blocker = $InputBlocker
@onready var pointer = $Pointer
@onready var interactives = $Interactives


func _ready():
	visibility_changed.connect(_on_visibility_changed)


func _process(delta):
	input_blocker.visible = not focus.active
	pointer.visible = focus.active

	for interactive in interactives.get_children():
		if "enabled" in interactive:
			interactive.enabled = visible and focus.active


func _on_visibility_changed():
	if visible:
		focus.push()
	else:
		focus.pop()


func _unhandled_input(event):
	if event.is_action_pressed("k_interact") or event.is_action_pressed("c_cancel"):
		if visible and focus.active:
			var scene_id = Service.of("SceneManager").scene_id
			var id = "%s.%s" % [scene_id, "exit_box"]
			Story.start_short(id)
