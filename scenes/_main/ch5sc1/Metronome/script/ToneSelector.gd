extends Area2D

signal tone_selector_interacted(time_signature)

@onready var tween = Threen.new()
@onready var collision = $CollisionShape2D

var current_time_signature = 0
var time_signature = ["2/4", "3/4", "4/4", "6/4"]
var start_position


func _ready():
	add_child(tween)
	input_event.connect(_on_tone_selector_input_event)
	start_position = position


func disable_interaction(enable):
	collision.disabled = enable


func _on_tone_selector_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			change_time_signature()
			tone_selector_interacted.emit(time_signature[current_time_signature])


func change_time_signature():
	current_time_signature += 1
	if current_time_signature == time_signature.size():
		current_time_signature = 0

	tween.interpolate_property(
		self,
		"position:x",
		position.x,
		start_position.x + (current_time_signature * 5),
		0.2,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN_OUT
	)
	tween.start()
