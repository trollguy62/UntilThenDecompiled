extends TextureRect

const HitResult = preload("res://modules/rhythm-minigame/classes/judgment/HitResult.gd")
const FLOOD_FILL_WHITE = preload("res://modules/rhythm-minigame/assets/mania/shaders/FloodFillWhite.material")

@export var action_name: String
@export var texture_unpressed: Texture
@export var texture_pressed: Texture
@export var use_material_for_pressed: bool = false
@export var alt_material: Material

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var judgementText = $Anchor/JudgmentText
@onready var judgementHighlight = $judgmentHighlight
@onready var hitEffect = $HitEffect
@onready var control_label = $ControlLabel



func _ready():
	if !texture_pressed:
		texture_pressed = texture

	update_controls()
	Game.config.remapped.connect(_on_input_remapped)
	visibility_changed.connect(_on_visibility_changed)


func _on_input_remapped(action: String, ev: InputEventKey):
	update_controls()


func _on_visibility_changed():
	update_controls()


func update_controls():
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventKey:
			control_label.text = ev.as_text()


func pop():
	if ap.is_playing():
		ap.stop()
	ap.play("pop")


func update_state(new_state: bool):
	if new_state:
		if use_material_for_pressed:
			material = alt_material
		else:
			texture = texture_pressed
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		if material:
			material = null
		texture = texture_unpressed
		modulate = Color(1.0, 1.0, 1.0, 0.8)


func apply_hit_result(hit_result):
	judgementText.apply_result(hit_result)
	judgementHighlight.apply_result(hit_result)

	if hit_result.type != HitResult.HIT_RESULT_MISS:
		play_hit_effect(hit_result)


func play_hit_effect(hit_result):
	for i in hitEffect.get_children():
		match hit_result.type:
			HitResult.HIT_RESULT_PERFECT:
				i.modulate = Color(0.556863, 1, 0.678431)
			HitResult.HIT_RESULT_GREAT:
				i.modulate = Color(1, 0.992157, 0.556863)

		i.restart()
		i.emitting = true
