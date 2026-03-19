extends Area2D

signal winding_key_interacted(energy_increase)

@onready var winding_key_sprite = $AnimatedSprite
@onready var collision = $CollisionShape2D
@onready var wind_up_audio = $WindUpAudio

var energy_increase = 45


func _ready():
	input_event.connect(_on_winding_key_input_event)


func _on_winding_key_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			wind_up()


func disable_interaction(enable):
	collision.disabled = enable


func wind_up():
	disable_interaction(true)
	winding_key_sprite.play("turn")
	wind_up_audio.play()

	await winding_key_sprite.animation_finished
	winding_key_sprite.play("idle")
	disable_interaction(false)
	winding_key_interacted.emit(energy_increase)
