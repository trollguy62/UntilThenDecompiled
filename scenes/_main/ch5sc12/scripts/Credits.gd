extends PanelContainer

signal credits_finished

@onready var tween = $Tween
@onready var label = $RichTextLabel

@export var roll_on_ready = false
@export_multiline var credits : Array[String]


func _ready():
	label.modulate = Color.TRANSPARENT

	if roll_on_ready:
		roll()


func roll():
	var scene = Utils.get_root_scene()
	scene.pausable = false

	for text in credits:
		label.bbcode_text = "[center]%s[/center]" % _get_position(text).strip_edges()
		await _fade_label(true)
		await Utils.wait(3)
		await _fade_label(false)
		await Utils.wait(0.5)

	credits_finished.emit()


func _fade_label(fade_in: bool):
	var to = label.modulate
	to.a = 1 if fade_in else 0

	tween.interpolate_property(label, "modulate", label.modulate, to, 1)
	tween.start()
	await tween.tween_completed


func _next():
	Game.go_to_main_menu()


func _get_position(credit: String):
	# TODO: Change to regex
	var translated_text: String

	if "[tr]" in credit:
		var string = credit.replace("[tr]", ",").replace("[/tr]", ",")
		var text_arr = string.split(",")

		for text in text_arr:
			translated_text += tr(text)

		return translated_text
	else:
		return credit
