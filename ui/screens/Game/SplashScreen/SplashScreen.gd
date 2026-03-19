extends Panel

signal finished

@export var textures: Array[Texture]
@export var legal_lines: Array[String]
@export var disclaimers: Array[String]

@export var fade_duration: float
@export var display_duration: float
@export var disclaimer_duration: float

@onready var content = $Content
@onready var logo = $Content/TextureRect
@onready var legal_line = $Content/LegalLine
@onready var disclaimer = $Content/Disclaimer


func _ready():
	assert(textures.size() == legal_lines.size())

	logo.visible = false
	legal_line.visible = false
	disclaimer.visible = false
	content.modulate = Color.WHITE


func start():
	content.modulate = Color.TRANSPARENT

	logo.visible = true
	legal_line.visible = true

	for i in range(textures.size()):
		logo.texture = textures[i]
		legal_line.text = legal_lines[i]

		await _fade_in(fade_duration)
		await Utils.wait(display_duration)
		await _fade_out(fade_duration)

	logo.queue_free()
	legal_line.queue_free()

	# Disclaimers
	disclaimer.visible = true

	for text in disclaimers:
		disclaimer.text = text

		await _fade_in(fade_duration)
		await Utils.wait(disclaimer_duration)
		await _fade_out(fade_duration)

	disclaimer.queue_free()

	finished.emit()


func _fade_in(duration):
	await _fade(true, duration)


func _fade_out(duration):
	await _fade(false, duration)


func _fade(into: bool, duration: float):
	var to = Color.WHITE if into else Color.TRANSPARENT
	var tween = create_tween().set_parallel(true)
	tween.tween_property(content, "modulate", to, duration)
	await tween.finished
